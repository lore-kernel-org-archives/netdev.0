From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 13/30] net: Don't do pointless kmalloc return value
	casts in zd1211 driver
Date: Thu, 30 Aug 2007 15:19:53 -0700
Message-ID: <1188512393.6062.156.camel@localhost>
References: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com>
	 <d551047daed1cb4d9de1eff956268a468c9837f6.1187912217.git.jesper.juhl@gmail.com>
	 <46D70467.1040109@gentoo.org>
	 <9a8748490708301320o49d8e794vc5c37ffc938006f1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jesper Juhl <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9a8748490708301320o49d8e794vc5c37ffc938006f1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-08-30 at 22:20 +0200, Jesper Juhl wrote:
> Ok, I must admit I didn't check with sparse since it seemed pointless
> - we usually never cast void pointers to other pointer types,
> specifically because the C language nicely guarantees that the right
> thing will happen without the cast.  Sometimes we have to cast them to
> integer types, su sure we need the cast there.   But what on earth
> makes a "zd_addr_t *" so special that we have to explicitly cast a
> "void *" to that type?

http://marc.info/?l=linux-netdev&m=117113743902549&w=1
