From: Lincoln Dale <ltd@cisco.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Wed, 12 Jun 2002 22:44:44 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <aee158$16t$2@main.gmane.org>
References: <5.1.0.14.2.20020612221925.0283fb18@mira-sjcm-3.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: Horst von Brand <vonbrand@inf.utfsm.cl>,
   "David S. Miller" <davem@redhat.com>, Ben Greear <greearb@candelatech.com>,
   <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <Pine.GSO.4.30.0206120829240.799-100000@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

At 08:33 AM 12/06/2002 -0400, jamal wrote:
> > i know of many many folk who use transaction logs from HTTP caches for
> > volume-based billing.
> > right now, those bills are anywhere between 10% to 25% incorrect.
> >
> > you call that "extremely limited"?
>
>Surely, you must have better ways to do accounting than this -- otherwise
>you deserve to loose money.

many people don't have better ways to do accounting than this.

in the case of Squid and Linux, they're typically using it because its 
open-source and "free".

they want to use HTTP Caching to save bandwidth (and therefore save money), 
but they also live in a regime of volume-based billing.  (not everywhere on 
the planet is fixed-$/month for DSL).

the unfortunate solution is to use HTTP Transaction logs, which count 
payload at layer-7, not payload+headers+retransmissions at layer-3.

> > of course, i am doing exactly what Dave said to do -- maintaining my own
> > out-of-kernel patch -- but its a pain, i'm sure it will soon conflict with
> > stuff and is a damn shame - it isn't much code, but Dave seems pretty
> > steadfast that he isn't interested.
>
>You havent proven why its needed. And from the looks of it you dont even
>need it.

i don't need it because i already have it in my kernel.
but thats where it ends -- its destined to forever be a private patch.

>If 3 people need it, then i would like to ask we add lawn mower
>support that my relatives have been asking for the last 5 years.

lawn-mower support sounds like a userspace application to me.


cheers,

lincoln.

