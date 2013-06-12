From: Oded Gabbay <ogabbay@advaoptical.com>
Subject: Re: [PATCH] MDIO: FSL_PQ_MDIO: Fix bug on incorrect offset of tbipa
 register
Date: Wed, 12 Jun 2013 16:09:35 +0300
Message-ID: <51B8730F.2030606@advaoptical.com>
References: <1371041258-15298-1-git-send-email-ogabbay@advaoptical.com> <51B871CB.1090808@tabi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <benh@kernel.crashing.org>, <paulus@samba.org>,
	<leoli@freescale.com>, <galak@kernel.crashing.org>,
	<B38951@freescale.com>, <Dongsheng.Wang@freescale.com>,
	<bigeasy@linutronix.de>, <stef.van.os@prodrive.nl>,
	<davem@davemloft.net>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Timur Tabi <timur@tabi.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51B871CB.1090808@tabi.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oded Gabbay wrote:
>> Note: This patch may break MDIO functionallity of some old 
>> Freescale's SoC
>> until Freescale will fix their device tree files. Basically, every 
>> device tree
>> which contains an mdio device that is compatible to "fsl,gianfar-tbi" 
>> should be
>> examined.
>
> On 06/12/2013 04:04 PM, Timur Tabi wrote:
> I haven't had a chance to review the patch in detail, but I can tell 
> you that breaking compatibility with older device trees is 
> unacceptable.  You need to add some code, even if it's an ugly hack, 
> to support those trees.
>
I generally agree with this statement except that without this patch, 
almost ALL of Freescale's SoC that uses "fsl,gianfar-tbi" are broken, 
including the older ones. At least this patch fixes some of the device 
trees. Because I'm not working at Freescale, I have a very limited 
access to a few SoC which I could test this patch on. I think it is 
Freescale's responsibility to release a complementary patch to fix the 
rest of the SoC device trees.

Oded
