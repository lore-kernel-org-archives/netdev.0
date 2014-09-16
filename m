From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Qdisc: Measuring Head-of-Line blocking with netperf-wrapper
Date: Tue, 16 Sep 2014 09:30:16 -0700
Message-ID: <1410885016.7106.203.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140915184517.6c5474e5@redhat.com>
	 <20140916152221.41811287@redhat.com>
	 <1410875959.7106.200.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140916175600.018350fe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:46162 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754323AbaIPQaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 12:30:17 -0400
Received: by mail-pa0-f51.google.com with SMTP id kx10so113395pab.38
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 09:30:17 -0700 (PDT)
In-Reply-To: <20140916175600.018350fe@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-16 at 17:56 +0200, Jesper Dangaard Brouer wrote:
> On Tue, 16 Sep 2014 06:59:19 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > With the TCP usec rtt work I did lately, you'll get more precise results
> > from a TCP_RR flow, as Tom and I explained.
> 
> Here you go, developed a new test:

Just to make sure I understand (sorry I dont have time going all your
graphs right now)

The target of your high prio flow is different from target of the
antagonist flows ?

Otherwise, you are not only measuring head of line blocking of your
host, but the whole chain, including scheduling latencies of the
(shared) target.
