From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [2.6 patch] make UNIX a bool
Date: Sat, 25 Feb 2006 18:28:11 +0100
Message-ID: <1140888491.2991.31.camel@laptopd505.fenrus.org>
References: <20060225160150.GX3674@stusta.de>  <44009024.5050105@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932366AbWBYR21@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <44009024.5050105@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-02-25 at 09:13 -0800, Stephen Hemminger wrote:
> Adrian Bunk wrote:
> > CONFIG_UNIX=m doesn't make much sense.
> >
> >
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> >
> >
> >   
> Why? You can build unix domain sockets as a loadable module and
> it runs fine (or it did last I tried). Whether that makes sense from a 
> distribution point of
you didn't use to when modutils used unix sockets internally :)

unix also needs a bunch of deeply internals exported that apparently
people want to play with...
