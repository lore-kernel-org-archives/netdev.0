From: Michael Brade <brade@informatik.uni-muenchen.de>
Subject: Re: r8169 hard-freezes the system on big network loads
Date: Thu, 15 Sep 2011 12:26:35 +0200
Message-ID: <201109151226.35055.brade@informatik.uni-muenchen.de>
References: <201108141308.28140.kjun-chen@sambodha.org> <201109142336.17291.brade@informatik.uni-muenchen.de> <20110915000332.GA13821@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Hayes <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acheron.ifi.lmu.de ([129.187.214.135]:43993 "EHLO
	acheron.ifi.lmu.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932312Ab1IOK1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2011 06:27:22 -0400
In-Reply-To: <20110915000332.GA13821@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 September 2011 02:03:32 Francois Romieu wrote:
> Michael Brade <brade@informatik.uni-muenchen.de> :
> [...]
>
> > ok, good news: I did not experience any freeze anymore even though I
> > transfered 60 GB. And I applied both of your patches and
> >
> > -                   if (status & RxFOVF) {
> > -                           rtl8169_schedule_work(dev,
> > rtl8169_reset_task); -                          
> > dev->stats.rx_fifo_errors++;
> > -                   }
>
> It should not be necessary to remove this part : the status mask is
> supposed to take care of it. One of my patches is wrong if this part
> needs to go away.

ok, I only removed it because you told me so the first time.

> [...]
>
> > so yes but what do you mean with "no real network traffic"? I still get
> > 100 MB/s.
>
> 100 MB/s as 100 Mbyte/s on a gigabit link or 100 Mbit/s on a {gigabit /
> fast} ethernet link ?

100 Mbytes on a gigabit link, so almost 100% usage (with ups and downs, of course; maybe 
between 90 MB/s and 112 MB/s).

thanks,
  Michael
