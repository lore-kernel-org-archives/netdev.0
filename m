From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: [PATCH 2.6] natsemi.c NAPI
Date: Mon, 27 Sep 2004 19:30:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5cac192f04092710304a3d28b2@mail.gmail.com>
References: <20040919163642.GC1307@sunbeam.de.gnumonks.org>
	 <4155D781.8050700@colorfullife.com>
	 <20040927091148.GF3236@sunbeam.de.gnumonks.org>
	 <16727.60345.857450.162620@robur.slu.se>
Reply-To: Eric Lemoine <eric.lemoine@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <robert.olsson@data.slu.se>
In-Reply-To: <16727.60345.857450.162620@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>  > I think this overall problem can be solved if there was some per-device
>  > variable that saves the IntrStatus until the NAPI callback gets
>  > scheduled. What do you think?  This wouldn't even need some locking,
>  > since interrupts would be disabled before the field is updated, and not
>  > re-enabled before the field is read by the NAPI callback?
>  >
>  > I was surprised that this solution is not suggested in the NAPI-HOWTO.txt, so I though there must be an error in my proposal...
>  >
>  > By using such a scheme, isn't it also possible to only offload RX into
>  > the NAPI callback with clear-on-read devices?
>  >
> 
>  e1000 used such technique before.If a remember correctly IntrStatus was
>  saved in device priv struct.

That's also how it is done in current sungem.

-- 
Eric
