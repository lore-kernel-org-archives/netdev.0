From: jamal <hadi@cyberus.ca>
Subject: Re: tulip NAPI patch that works with 2.4.20-pre9 or so?
Date: Mon, 21 Oct 2002 08:49:09 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210210826440.17911-100000@shell.cyberus.ca>
References: <3DB3948E.6080907@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DB3948E.6080907@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Theres a 2419 patch that should work for you at:
http://www.cyberus.ca/~hadi/tulip-2419-napi-nifd.gz

Also pick a small patch on top of this at:
http://www.cyberus.ca/~hadi/patch-napi-tulip-20020915

Now if you wanna get adventorous why not pick:
http://www.cyberus.ca/~hadi/tulip-feed.tgz
You still need that second patch;
In addition to solve your skb problem pick Roberts latest
recycling patch at:
ftp://robur.slu.se/pub/Linux/net-development/skb_recycling/recycle12.pat
The driver i pointed to above has skb-recycling built in.

cheers,
jamal

On Sun, 20 Oct 2002, Ben Greear wrote:

> Robert Olsson wrote:
> > Ben Greear writes:
> >  > The latest NAPI tulip patch I could find (tulip-020922.pat)
> >  > will not load.  The problem appears that the tulip_misc.c file
> >  > no longer exists...
> >
> >  :-( I'll look into it.
>
> It works if you fix up the Makefile to not compile tulip_misc.c
> and if you change tulip.h to not define EXTRA_STATS.
>
> I'm running it now...initial 5 minutes are a definate improvement
> over the in-kernel code....now, if it will only remain stable :)
>
> Ben
>
> --
> Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
> President of Candela Technologies Inc      http://www.candelatech.com
> ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
>
>
>
