From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Sat, 01 Oct 2011 15:43:02 -0400
Message-ID: <6.2.5.6.2.20111001153616.05c03658@binnacle.cx>
References: <6.2.5.6.2.20111001141002.05af4b20@binnacle.cx>
 <1317496303.3802.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.binnacle.cx ([74.95.187.105]:56870 "EHLO mx.binnacle.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751087Ab1JATti convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2011 15:49:38 -0400
In-Reply-To: <1317496303.3802.25.camel@edumazet-laptop>
References: <6.2.5.6.2.20111001141002.05af4b20@binnacle.cx>
 <1317496303.3802.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At 09:11 PM 10/1/2011 +0200, Eric Dumazet wrote:
>Le samedi 01 octobre 2011 =C3  14:16 -0400, starlight@binnacle.cx=20
>a =C3=A9crit :
>
>2.6.32 has a perf tool, that can really help to
>spot in a few minutes hot spots. That would
>definitely help to further diagnose what could be
>the problem in your workload.

Ok.

=46irst I'm really interested in turning off all the
container stuff, so I'm building a 2.6.32.27
kernel that way to see the effect.

If that doesn't fix it, I'll dig in with 'perf'
in the RHEL-like build I've tried and found
performs the same as RH.

If it does fix it, I doubt much can be done
except compile kernels without it.

Haven't been paying attention to containers
but now that I've read up on them, it sure
sounds like the kind of feature that can
double the length of an efficient code-path.
Sometimes performance is traded for new features
and that's just the way it is.  As long as
some way to maintain efficiency by shedding
them is available, I'll be happy.  Our workload
is essentially a HPC one, and like most in the
HPC realm, we need to be as close to the metal
as possible.
