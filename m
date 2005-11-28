From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: KERNEL: assertion (!sk->sk_forward_alloc) failed
Date: Mon, 28 Nov 2005 08:44:05 -0800
Message-ID: <4807377b0511280844w5ab2cb95y9955a62c0efe2f9d@mail.gmail.com>
References: <20051128123601.GA32346@king.bitgnome.net>
	 <dmf1kn$t2s$1@news.cistron.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751302AbVK1QoI@vger.kernel.org>
To: Miquel van Smoorenburg <miquels@cistron.nl>, nipsy@bitgnome.net
In-Reply-To: <dmf1kn$t2s$1@news.cistron.nl>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This should really be on netdev, so I copied it.

On 11/28/05, Miquel van Smoorenburg <miquels@cistron.nl> wrote:
> In article <20051128123601.GA32346@king.bitgnome.net>,
> Mark Nipper  <nipsy@bitgnome.net> wrote:
> >        I received the following in my system logs recently:
> >---
> >Nov 27 22:56:20 king kernel: KERNEL: assertion (!sk->sk_forward_alloc)
> >failed at net/core/stream.c (279)
> >Nov 27 22:56:20 king kernel: KERNEL: assertion (!sk->sk_forward_alloc)
> >failed at net/ipv4/af_inet.c (151)
> >
> >        All I could find related to this was some potential bugs
> >mentioned in 2.6.9 and in particular with relation to TSO.
> >However, I'm running a vanilla 2.6.13.4 at the moment.  But, I do
> >have an e1000 and checking ethtool does show TSO on.
>
> I'm seeing the same on 2.6.14.2, also with e1000. It wasn't there on
> 2.6.11.12 which I was running previously.

I don't believe this is related to e1000 because we don't mess with
the sock (sk) struct.  Did you try disabling TSO?  I bet the netdev
guys can help.
