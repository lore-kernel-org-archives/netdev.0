From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Bug#396185: sky2 freezes in 2.6.17-2-686. Maintainer confirms that it should be fixed in 2.6.19-git tree.
Date: Tue, 19 Dec 2006 08:38:59 +0300
Message-ID: <20061219053858.GB28980@2ka.mipt.ru>
References: <20061031093051.GA3323@2ka.mipt.ru> <20061031093455.GX13178@baikonur.stro.at> <20061031094424.GA19052@2ka.mipt.ru> <20061116173532.GA10653@2ka.mipt.ru> <20061116093821.318efbe6@freekitty> <20061118112134.GI4213@nancy> <20061118112527.GA25624@2ka.mipt.ru> <20061129052948.GC13488@2ka.mipt.ru> <20061217141547.GA23387@2ka.mipt.ru> <20061218091728.2e1cf58b@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: maximilian attems <maks@sternwelten.at>, 396185@bugs.debian.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55630 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752532AbWLSFjf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Dec 2006 00:39:35 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061218091728.2e1cf58b@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 18, 2006 at 09:17:28AM -0800, Stephen Hemminger (shemminger@osdl.org) wrote:
> > Bug with freeze also exists in 2.6.18-3 (package version 2.6.18-7) - no
> > messages in dmesg, no interrupts.
> > It is dual lan board with only one port being used.
> > rmmod/modprobe sequence brings NIC back to working mode.
> > 
> 
> What are the statistics (ethtool -S eth0) after the hang.
> One user reported a single pause frame being sent. I have can't reproduce
> a hang with similar hardware, so am beginning to wonder if the problem is
> pause negotiation, and interoperability problems??  Maybe the receiver gets
> overloaded and sends one pause frame, but the switch can't really do flow
> control and gets stuck.  I do stress tests with either a direct connect cable,
> or with a switch that does flow control and lots of packets and see the driver/hardware
> successfully doing flow control.
 
Load was quite small - no huge transfers, just usual couple of ssh
sessions to read mails, web. Switch is dlink dgs-1216t gigabit one which
supports flow control (according to dlink spec).

I will dump statistic and registers next time it happens - I do not know
how to reproduce it on demand.
 
> -- 
> Stephen Hemminger <shemminger@osdl.org>

-- 
	Evgeniy Polyakov
