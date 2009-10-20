From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with  "alive" pppoe interfaces
Date: Tue, 20 Oct 2009 14:36:49 +0300
Message-ID: <200910201436.50249.denys@visp.net.lb>
References: <200910190002.39937.denys@visp.net.lb> <200910200308.57381.denys@visp.net.lb> <aa79d98a0910192004g43de90d5p823293b888cf0c1d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Michal Ostrowski <mostrows@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:52638 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbZJTLis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 07:38:48 -0400
In-Reply-To: <aa79d98a0910192004g43de90d5p823293b888cf0c1d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 20 October 2009 06:04:35 Cyrill Gorcunov wrote:
> On 10/20/09, Denys Fedoryschenko <denys@visp.net.lb> wrote:
> > On Tuesday 20 October 2009 00:22:39 Michal Ostrowski wrote:
> >> I'm assuming that there was a race in us sending patches at nearly the
> >> same
> >> time I'm convinced now that the flush_lock can die, and the patch I sent
> >> out kills it.
> >
> > o_O
> >
> > I am drowning in patches. Just let me know which one to test :-)
>
> Oh ;) Try out latest Michal's patch (and then mine). I'll continue
> digg this issue at next spare time slot. Thanks!
Tried your patch, panic almost immediately
Here is a text of panic message over netconsole
http://www.nuclearcat.com/files/panic_pppoe3.txt
It is  different now, before it was pppoe_device_event, now in pppoe_rcv

