From: kuznet@ms2.inr.ac.ru
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Thu, 17 Jul 2003 04:03:56 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307170003.EAA12843@dub.inr.ac.ru>
References: <Pine.LNX.4.44.0307160901560.20100-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi (Pekka Savola)
In-Reply-To: <Pine.LNX.4.44.0307160901560.20100-100000@netcore.fi> from "Pekka Savola" at Jul 16, 2003 09:03:57 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> > > What happens when you do "ping6 3FFE:FFFF:A:B::1" ?
> > 
> > Hey, you have lost track, rewind several mails ago. 
> 
> Nope.  I'm just pointing out the general concept.
> 
> > Of course, ping and
> > any other protocols will work, how can it not work? :-)
> 
> It has been made shown to work on other platforms, so why not Linux?

ping did, does and will work and I do not understand what you want
to say or ask. Do you want to know how it works?

Well, IPv6 stack looks up the address in routing tables, finds the route,
sees that it is on-link, sends NDISC, receiver replies, we create a frame
and send the echo request. To continue? :-)

Alexey
