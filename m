From: Horst von Brand <vonbrand@inf.utfsm.cl>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Wed, 12 Jun 2002 08:11:45 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae7dvs$vc7$2@main.gmane.org>
References: <greearb@candelatech.com>
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: Message from Ben Greear <greearb@candelatech.com>
   of "Tue, 11 Jun 2002 23:26:40 MST." <3D06E9A0.5060801@candelatech.com>
List-Id: netdev.vger.kernel.org

[Cc:'s stripped]

Ben Greear <greearb@candelatech.com> said:
> Pekka Savola wrote:
> > Just to chime in my support (not that I don't think anyone needs it), I 
> > think socket-based counters are An Extremely Bad Idea.  

[...]

> If they are useful to some people, and have zero performance affect on others
> (due to being a configurable kernel feature), then what is your
> complaint?

That it adds code, which impacts _everybody_ futzing around in that area,
specially if it is a configurable option (this means multiplying the
possible configurations to be tested).

> I see two reasons left to dislike this feature:
> 
> 1)  General increase in #ifdef'd code.  This actually seems like
>     a pretty good argument, but I haven't seen anyone mention it
>     specifically.

Right.

> 2)  General dislike for a feature that one personally has no use for.
>     Seems to be Dave's main (professed) excuse.

General dislike for adding features of _extremely_ limited (debugging!) use?
-- 
Dr. Horst H. von Brand                   User #22616 counter.li.org
Departamento de Informatica                     Fono: +56 32 654431
Universidad Tecnica Federico Santa Maria              +56 32 654239
Casilla 110-V, Valparaiso, Chile                Fax:  +56 32 797513
