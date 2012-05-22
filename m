From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp timestamp issues with google servers
Date: Tue, 22 May 2012 19:53:43 +0200
Message-ID: <1337709223.3361.281.camel@edumazet-glaptop>
References: <87r4ujno34.fsf@tucsk.pomaz.szeredi.hu>
	 <1337278363.3403.39.camel@edumazet-glaptop>
	 <87zk90s0em.fsf@tucsk.pomaz.szeredi.hu>
	 <1337701259.3361.208.camel@edumazet-glaptop>
	 <87mx50rz34.fsf@tucsk.pomaz.szeredi.hu>
	 <CAGK4HS9cGnOcoLAL1pggWvMG1B40rWyqc3BHsddUvnii4EvTcQ@mail.gmail.com>
	 <1337705285.3361.229.camel@edumazet-glaptop>
	 <CAGK4HS8b2GSub02ShhofCrYQ1XnOT7Rrjm3KcOhCFFkUF1QqBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Miklos Szeredi <miklos@szeredi.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63215 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038Ab2EVRxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 13:53:49 -0400
In-Reply-To: <CAGK4HS8b2GSub02ShhofCrYQ1XnOT7Rrjm3KcOhCFFkUF1QqBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-22 at 10:38 -0700, Vijay Subramanian wrote:
> >> Maybe tcptraceroute[1] can help you figure this out.
> >>
> >> [1] http://michael.toren.net/code/tcptraceroute/
> >
> >
> > The transparent proxy can intercept TCP connections to port 80/443, and
> > let ICMP being NATed by the box.
> 
> Just to be clear..tcptraceroute uses TCP SYN packets to trace the
> route instead of using ICMP packets used by vanilla traceroute
> precisely because
> of the issue you raised.
> The idea is that if the connection is getting terminated at a
> middlebox, the trace will end there. Otherwise, the trace route will
> end
> at destination (google in this case). This avoids the problems of ICMP
> and TCP flows being treated differently by the middlebox.
> Is this approach workable?

Yes probably, thanks for detailed description (I indeed thought it was
traceroute)
