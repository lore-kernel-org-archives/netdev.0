From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: ports beeing reused too fast
Date: Sat, 9 May 2009 22:41:41 +0300
Message-ID: <200905092241.41515.opurdila@ixiacom.com>
References: <200905082311.09414.opurdila@ixiacom.com> <4A059E75.7060008@cosmosbay.com> <20090509153135.04874f72.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:3101 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753219AbZEITmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 15:42:50 -0400
In-Reply-To: <20090509153135.04874f72.billfink@mindspring.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 09 May 2009 22:31:35 Bill Fink wrote:

> > Normally, the client machine should not reuse a port during the TIME_WAIT
> > duration (TCP_TIMEWAIT_LEN being 60 seconds on linux). Port selection
> > being random or sequential, it should avoid all ports recently used.
> >
> > Maybe this firewall has a longer TIME_WAIT enforcement (something like 2
> > minutes)
>
> But he had 19 ports being reused after only 1000 connect()s, which
> with his stated ~360 (I'm assuming per second) connection rate,
> would only take about 3 seconds.
>

Time-wait doesn't apply in this case, because connections are closed by the 
server, thus they don't have to go through the time-wait state.

Thanks,
tavi


