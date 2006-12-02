From: Tino Keitel <tino.keitel@tikei.de>
Subject: Re: 2.6.19: very low transmit speed after suspend/resume with Sky2
Date: Sat, 2 Dec 2006 14:18:33 +0100
Message-ID: <20061202131833.GA3673@thinkpad.home.local>
References: <20061202091626.GA20734@thinkpad.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:51375 "EHLO
	eazy.amigager.de") by vger.kernel.org with ESMTP id S1423816AbWLBNSb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 08:18:31 -0500
Received: from thinkpad.home.local (port-212-202-201-86.dynamic.qsc.de [212.202.201.86])
	by eazy.amigager.de (Postfix) with ESMTP id EBF1825C3AE
	for <netdev@vger.kernel.org>; Sat,  2 Dec 2006 14:18:29 +0100 (CET)
Received: from scorpion by thinkpad.home.local with local (Exim 4.63)
	(envelope-from <tino.keitel@tikei.de>)
	id 1GqUlF-0000xx-E3
	for netdev@vger.kernel.org; Sat, 02 Dec 2006 14:18:33 +0100
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20061202091626.GA20734@thinkpad.home.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 02, 2006 at 10:16:28 +0100, Tino Keitel wrote:
> Hi folks,                                            
>                                                      
> since 2.6.19 I have the problem that I get lousy transmit speeds of < 1 
> mbit/s.
> 
> Here is a quick test, the 5th column is the transfer speed in mbit/s:
> 
> From the affected machine to my laptop over WLAN (the affected machine
> is connected to a Fast Ethernet switch):
> 
> $ nttcp -r -l 1400 -n 500 dose
> l   700000    8.16   0.04    0.6867    155.5469   824  101.04   22887.6     
> 1   700000    8.15   0.00    0.6873 560000.0000   500  61.37    50000000.0    
> 
> Only 0,68 mbit/s during transmit. :-(
> 
> From my laptop to the affected machine:
> 
> $ nttcp -l 1400 -n 5000 dose
> l  7000000    2.21   0.03   25.3427   1999.8572  5000  2262.74  178558.7     
> 1  7000000    2.25   0.07   24.8363    823.4810  9268  4110.41  136286.1 
> 
> This is ok, 25 mbit/s during receive, limited by the WLAN in the
> laptop.
> 
> After reboot:
> 
> $ nttcp -l 1400 -n 5000 dose
> l  7000000    2.04   0.03   27.5005   1749.8906  5000  2455.40  156240.2
> 1  7000000    2.08   0.06   26.9843    999.9464  9455  4556.00  168830.2
> 
> Now I got 27 mbit/s during receive, that's ok for WLAN.

Sorry, I should give the number for _transmit_ here. This was ok, too.

Regards,
Tino
