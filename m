From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI:  dev.c change to net_rx_action algorithm.
Date: Fri, 8 Nov 2002 23:58:07 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211082351540.16986-100000@shell.cyberus.ca>
References: <3DCC9535.3050506@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DCC9535.3050506@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Fri, 8 Nov 2002, Ben Greear wrote:

> I'm looking for the real cause.

No you are not. You are looking for something that will give you some
quick fix given your current setup.

> The current code does not work
> as I want it to.  So, I'm changing things.  I would love to try
> out any patch you might feel like contributing.

Be systematic about and prove where things are wrong. I even made some
suggestions to you a while back.

>
>  From what I can tell, the old code punishes interfaces who are
> running slower at any given time.

You are totaly wrong. Go and read the paper on DRR.

> My change, I believe, will
> allow slower interfaces to gather a bit more quota so that when
> they are hit with a burst of traffic, they can spend a little
> extra time to clear their buffers.
>
> I would also welcome any argument as to why my code is worse
> than the existing code.  And theoretical papers be damned,
>

You havent proved anything up to this point other than handwaving.
So i dont think you should be damning anything.

> I see better results with the change below.  Why is that?
>

You tell me.

cheers,
jamal
