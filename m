From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: Use ERR_CAST inlined function instead of
 ERR_PTR(PTR_ERR(...))
Date: Tue, 08 Oct 2013 10:37:25 +0200
Message-ID: <1381221445.13359.0.camel@jlt4.sipsolutions.net>
References: <1381190953-6362-1-git-send-email-duanj.fnst@cn.fujitsu.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7379@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: djduanjiong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Duan Jiong <duanj.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7379-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-10-08 at 09:33 +0100, David Laight wrote:

> >  	if (IS_ERR(key))
> > -		return ERR_PTR(PTR_ERR(key));
> > +		return ERR_CAST(key);
> 
> I suspect the old code is a deliberate attempt to indicate that it
> the error value that is being returned rather than the pointer.

I was under the impression that's what ERR_CAST means.

> Looking higher up that file there seems to be a fubar when setting
> up the TKIP key.
> It seems to put the same 6 bytes into every TID.
> (I'm sure seq_len shouldn't be ignored either.0

Both are fine.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
