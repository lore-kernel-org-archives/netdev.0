From: Timur Tabi <timur@tabi.org>
Subject: Re: [PATCH] MDIO: FSL_PQ_MDIO: Fix bug on incorrect offset of tbipa
 register
Date: Wed, 12 Jun 2013 08:04:11 -0500
Message-ID: <51B871CB.1090808@tabi.org>
References: <1371041258-15298-1-git-send-email-ogabbay@advaoptical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Oded Gabbay <ogabbay@advaoptical.com>, benh@kernel.crashing.org,
	paulus@samba.org, leoli@freescale.com, galak@kernel.crashing.org,
	B38951@freescale.com, Dongsheng.Wang@freescale.com,
	bigeasy@linutronix.de, stef.van.os@prodrive.nl, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371041258-15298-1-git-send-email-ogabbay@advaoptical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oded Gabbay wrote:
> Note: This patch may break MDIO functionallity of some old Freescale's SoC
> until Freescale will fix their device tree files. Basically, every device tree
> which contains an mdio device that is compatible to "fsl,gianfar-tbi" should be
> examined.

I haven't had a chance to review the patch in detail, but I can tell you 
that breaking compatibility with older device trees is unacceptable.  You 
need to add some code, even if it's an ugly hack, to support those trees.

-- 
Timur Tabi
