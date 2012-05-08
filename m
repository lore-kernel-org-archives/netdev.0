From: Ulisses Furquim <ulisses-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: batostr() function
Date: Tue, 8 May 2012 11:20:37 -0300
Message-ID: <CAA37ikbcPQ5UwX4Yfx9cg-J7uSFoEJmxv8fkn7Hj3b_=pUutMw@mail.gmail.com>
References: <1336391383.4325.24.camel@jlt3.sipsolutions.net>
	<CANq1E4QW4vSn_r9C=rirShE+-eyPjRX+b5tpC+mx69Hs6aEYqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Herrmann <dh.herrmann-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CANq1E4QW4vSn_r9C=rirShE+-eyPjRX+b5tpC+mx69Hs6aEYqQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

On Tue, May 8, 2012 at 10:30 AM, David Herrmann
<dh.herrmann-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> wrote:
>
> Hi Johannes
>
> On Mon, May 7, 2012 at 1:49 PM, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> wrote:
> > Really? 2 static buffers that are used alternately based on a static
> > variable? How can that possibly be thread-safe? That may work in very
> > restricted scenarios, but ...
>
> Looking at "git blame" it seems the whole function is still from
> linux-2.4. Looks like no-one ever noticed. I've sent a patchset fixing
> it, thanks.

Thanks for fixing it. I'm sure we haven't noticed but it's still weird
to have it this way. :-/

Regards,

--
Ulisses Furquim
ProFUSION embedded systems
http://profusion.mobi
Mobile: +55 19 9250 0942
Skype: ulissesffs
