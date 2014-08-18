From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] mac80211: fix channel switch for chanctx-based drivers
Date: Mon, 18 Aug 2014 08:59:49 -0500
Message-ID: <CA+55aFxSPqqxeF4okdo9836zikov8ah1wBxPe=ZaNEOYZJ-xfQ@mail.gmail.com>
References: <1408351816.29649.8.camel@dubbel>
	<1408360749-10233-1-git-send-email-michal.kazior@tieto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
To: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1408360749-10233-1-git-send-email-michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 18, 2014 at 6:19 AM, Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org> wrote:
>
> I've verified this fix with iwlmvm & 7260.

So I'm running a kernel with this manually applied, and so far so
good. But I don't know what actually triggered the problem, and it
definitely didn't happen all the time, so my testing of this is
dubious. But the patch certainly seems to match the symptoms. Thanks,

          Linus
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
