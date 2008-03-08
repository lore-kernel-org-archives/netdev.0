From: Komuro <komurojun-mbn@nifty.com>
Subject: Re: [BUG  kernel 2.6.25-rc3  IPV6]  ping6 -I eth0 ff02::1 causes
 system hang.
Date: Sat, 8 Mar 2008 13:44:10 +0900
Message-ID: <20080308134410.69d07a2d.komurojun-mbn@nifty.com>
References: <20071006132601.f944f461.komurojun@nifty.com>
	<20071014073658.d4352b8c.komurojun@nifty.com>
	<20080302210716.69727582.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760558AbYCHEsZ@vger.kernel.org>
In-Reply-To: <20080302210716.69727582.komurojun-mbn@nifty.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

>Hmm, I've never seen this on our testlab.  Anyone else?

Could you send 20(twenty) or more ping packets?


>It would be great if you have chance to bisect it...On Sun, 2 Mar 2008 21:07:16 +0900

The bad commit is below.

69cc64d8d92bf852f933e90c888dfff083bd4fc9 is first bad commit
commit 69cc64d8d92bf852f933e90c888dfff083bd4fc9
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Feb 11 21:45:44 2008 -0800

    [NDISC]: Fix race in generic address resolution

    Frank Blaschka provided the bug report and the initial suggested fix
    for this bug.  He also validated this version of this fix.




> Hi,
> 
> On kernel 2.6.25-rc3, IPV6 multicast ping causes system hang
> after sending several multicast ping packet.
> 
> >ping6 -I eth0 ff02::1 
> 
> This problem does not happen on kernel 2.6.24.
> (does not depend on NIC)

 
Best Regards
Komuro
 
 
