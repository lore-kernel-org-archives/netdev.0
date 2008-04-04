From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Why is tcp_reno_min_cwnd() ssthresh/2?
Date: Fri, 4 Apr 2008 11:31:14 -0700
Message-ID: <20080404113114.2181a146@extreme>
References: <aa7d2c6d0804031800r7d796b40oc011e684bcd2f0c0@mail.gmail.com>
	<7335583a0804031935g49a843dbq8b8c132411501a8b@mail.gmail.com>
	<1e41a3230804040924q34d009c9w97dded92f13392dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Xiaoliang David Wei" <davidwei79@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: "John Heffner" <johnwheffner@gmail.com>,
	"Lachlan Andrew" <lachlan.andrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:40032 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752067AbYDDSbW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 14:31:22 -0400
In-Reply-To: <1e41a3230804040924q34d009c9w97dded92f13392dc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Greetings all,
> 
> Apologies if this is a dumb question, but why does
> tcp_reno_min_cwnd()  return  ssthresh/2?
> 
> Since   ssthresh <- snd_cwnd/2   on loss, this looks like it tries to
> reduce  snd_cwnd  to 1/4 its value before a loss event, presumably
> then slow-starting back to half of the original  snd_cwnd.
> 
> As Tom Quetchenbach pointed out, it is also odd that  omitting
> min_cwnd()  from a congestion control module causes  ssthresh  to be
> used, giving different results from using  tcp_reno_min_cwnd().
> 
> Thanks,
> Lachlan

First sighed 5 years ago, and every times it comes up, the original
behaviour is retained.

http://oss.sgi.com/archives/netdev/2003-01/msg00114.html
