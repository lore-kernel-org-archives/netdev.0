From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [IPROUTE 01/05]: Use tc_calc_xmittime where appropriate
Date: Tue, 16 Jan 2007 13:48:51 +0100
Message-ID: <20070116124851.GC1003@ff.dom.local>
References: <20070116085611.GA1003@ff.dom.local> <45ACA6B6.1090902@trash.net> <20070116110244.GB1003@ff.dom.local> <45ACC504.4060208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:37685 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751066AbXAPMqn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jan 2007 07:46:43 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <45ACC504.4060208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 16, 2007 at 01:28:52PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > On Tue, Jan 16, 2007 at 11:19:34AM +0100, Patrick McHardy wrote:
> > ...
> > 
> >>Right, this changes it from long (tc_core_usec2tick) to unsigned
> >>int. It doesn't make any difference though, ... 
> > 
> > 
> > ... if we count out reading_time_2tick, of course.
> 
> And this is a problem why? In the worst case (NET_SCH_CLK_CPU,
> max rate 1/0.5us) it allows us to represent a transmission time
> of 2^32/1000000/2s (where 2 is tick_in_usec), which is roughly
> 2147s.
> 
> If you still have doubts, please use numbers to demonstrate the
> problem.

Sorry, I probably forgot to add "the face".

The only problem is that when reading a patch you have
to guess if this was considered by the author or as in
other place to check all next uses of double variable
to see they actually always store unsigned.

But probably I should correct readability of my posts,
too.

Jarek P.
