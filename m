From: Bastian Bittorf <bb-j3O8QLukP0Q@public.gmane.org>
Subject: Re: 'iw events' stops receiving events after a while on 4.9 + hacks
Date: Wed, 31 May 2017 10:18:36 +0200
Message-ID: <20170531081836.GC2849@medion.lan>
References: <d82d191e-8ede-68c6-c9e0-c381dc874d36@candelatech.com>
 <20170517100844.GC2849@medion.lan>
 <1495027835.2442.13.camel@sipsolutions.net>
 <fa96dfad-8d1b-c48f-df3b-3df0d548a5c6@candelatech.com>
 <1496150322.3327.9.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1496150322.3327.9.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> [31.05.2017 10:09]:
> > Is there any way to dump out the socket information if we reproduce
> > the problem?
> 
> I have no idea, sorry.
> 
> If you or Bastian can tell me how to reproduce the problem, I can try
> to investigate it.

there was an interesting fix regarding the shell-builtin 'read' in
busybox[1]. I will retest again and report if this changes anything.

bye, bastian

PS: @ben: are you also using 'iw event | while read -r LINE ...'?

[1]
https://git.busybox.net/busybox/commit/?id=f5470419404d643070db99d058405b714695b817
