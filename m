From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 hard-freezes the system on big network loads
Date: Thu, 15 Sep 2011 02:03:32 +0200
Message-ID: <20110915000332.GA13821@electric-eye.fr.zoreil.com>
References: <201108141308.28140.kjun-chen@sambodha.org> <201109112216.33579.brade@informatik.uni-muenchen.de> <20110913081126.GA20022@electric-eye.fr.zoreil.com> <201109142336.17291.brade@informatik.uni-muenchen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Hayes <hayeswang@realtek.com>
To: Michael Brade <brade@informatik.uni-muenchen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48600 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858Ab1IOAD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2011 20:03:59 -0400
Content-Disposition: inline
In-Reply-To: <201109142336.17291.brade@informatik.uni-muenchen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Brade <brade@informatik.uni-muenchen.de> :
[...]
> ok, good news: I did not experience any freeze anymore even though I 
> transfered 60 GB. And I applied both of your patches and 
> 
> -                   if (status & RxFOVF) {
> -                           rtl8169_schedule_work(dev, rtl8169_reset_task);
> -                           dev->stats.rx_fifo_errors++;
> -                   }

It should not be necessary to remove this part : the status mask is
supposed to take care of it. One of my patches is wrong if this part
needs to go away.

[...]
> > Are the symptoms in any way different or do you still notice more-or-less
> > periodic link-up messages and no real network traffic ?
> 
> dmesg looks like this:
> 
> [ 1611.380420] r8169 0000:13:00.0: eth0: link up
> [ 1611.995417] r8169 0000:13:00.0: eth0: link up
> [ 1612.323050] r8169 0000:13:00.0: eth0: link up
> [ 1612.574016] r8169 0000:13:00.0: eth0: link up

I will have to figure why there are so much of theses messages.

[...]
> so yes but what do you mean with "no real network traffic"? I still get
> 100 MB/s.

100 MB/s as 100 Mbyte/s on a gigabit link or 100 Mbit/s on a {gigabit / fast}
ethernet link ?

Thanks.

-- 
Ueimor
