From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH 2.6] natsemi.c NAPI
Date: Mon, 27 Sep 2004 12:30:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16727.60345.857450.162620@robur.slu.se>
References: <20040919163642.GC1307@sunbeam.de.gnumonks.org>
	<4155D781.8050700@colorfullife.com>
	<20040927091148.GF3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040927091148.GF3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 > I think this overall problem can be solved if there was some per-device
 > variable that saves the IntrStatus until the NAPI callback gets
 > scheduled. What do you think?  This wouldn't even need some locking,
 > since interrupts would be disabled before the field is updated, and not
 > re-enabled before the field is read by the NAPI callback?
 > 
 > I was surprised that this solution is not suggested in the NAPI-HOWTO.txt, so I though there must be an error in my proposal...
 > 
 > By using such a scheme, isn't it also possible to only offload RX into
 > the NAPI callback with clear-on-read devices?
 > 

 e1000 used such technique before.If a remember correctly IntrStatus was
 saved in device priv struct.

 Cheers.
						--ro
