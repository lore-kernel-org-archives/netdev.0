From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/5] net: thunderx: Switchon carrier only upon
 interface link up
Date: Wed, 02 Dec 2015 15:56:15 -0500 (EST)
Message-ID: <20151202.155615.518630269762334670.davem@davemloft.net>
References: <1449050777-37836-5-git-send-email-sunil.kovvuri@gmail.com>
	<00ec01d12cee$26a28a00$73e79e00$@samsung.com>
	<011f01d12cf4$de8bc7c0$9ba35740$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sunil.kovvuri@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com, sgoutham@cavium.com
To: p.fedin@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <011f01d12cf4$de8bc7c0$9ba35740$@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Fedin <p.fedin@samsung.com>
Date: Wed, 02 Dec 2015 14:30:37 +0300

>  Hello again!
> 
>> Subject: RE: [PATCH v2 4/5] net: thunderx: Switchon carrier only upon interface link up
>> 
>>  Just a reminder, we have issue with this one too, which is not addressed yet.
> 
>  I have examined the problem thoroughly and discovered that it is a problem with experimental BGX driver patches on my 4.2 host
> kernel build. It fails to send NIC_MBOX_MSG_BGX_LINK_CHANGE, so nothing works.
>  I have retested this series on top of 4.3 running on ThunderX. It has good BGX driver and everything works fine. Therefore, the
> whole series can be safely applied and...
> 
>  Tested-by: Pavel Fedin <p.fedin@samsung.com>

Ok, thanks for confirming things are fine now.

I'll apply this series.
