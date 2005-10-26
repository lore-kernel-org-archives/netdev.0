From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: [PATCH] kill massive wireless-related log spam
Date: Wed, 26 Oct 2005 23:43:59 +0200
Message-ID: <9a8748490510261443y7ea58a8amcb928135db91cb4f@mail.gmail.com>
References: <20051026042827.GA22836@havoc.gtf.org>
	 <200510261704.15366.ak@suse.de>
	 <9a8748490510260823s681a4d82k5efa5734486eda85@mail.gmail.com>
	 <AB480DAC-57B0-4125-8BA5-D6C715B693B6@able.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964949AbVJZVoE@vger.kernel.org>
To: "J.A. Magallon" <jamagallon@able.es>
In-Reply-To: <AB480DAC-57B0-4125-8BA5-D6C715B693B6@able.es>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/26/05, J.A. Magallon <jamagallon@able.es> wrote:
>
> On 2005.10.26, at 17:23, Jesper Juhl wrote:
>
> > On 10/26/05, Andi Kleen <ak@suse.de> wrote:
> >
> >> On Wednesday 26 October 2005 06:28, Jeff Garzik wrote:
> >>
> >>
> >>> Change this to printing out the message once, per kernel boot.
> >>>
> >>
> >> It doesn't do that. It prints it once every 2^32 calls. Also
> >>
> >
> > I noted that as well. How about just using something along the
> > lines of
> >
> > static unsigned char printed_message = 0;
> > if (!printed_message) {
> >     printk(...);
> >     printed_message++;
> > }
>
> Sorry, but why not the old good
>
>      printed_message = 1
>
> ??
> What kind of microoptimization is that ?
>
Does it really matter?   I needed to pick one of
printed_message=1; or printed_message++;
the end result is the same, so I just picked one at random.
But now that you mention it, I guess ++ would turn into "inc" which
should be faster than an assignment... but it *doesn't matter*... I
was not trying to optimize anything, just make the code work properly
- as in, only ever print the message once...


--
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
