From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] SUNRPC: Prevent kernel stack corruption on long values
 of flush
Date: Wed, 17 Oct 2012 15:02:33 -0400
Message-ID: <20121017190233.GA8630@fieldses.org>
References: <1342476086-21638-1-git-send-email-levinsasha928@gmail.com>
 <20120718173913.GA1298@fieldses.org>
 <CA+1xoqcgWTP8pAY3Ok2R0JM-ZXSkGroEvAFcqP0KaK=dABiTXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+1xoqcgWTP8pAY3Ok2R0JM-ZXSkGroEvAFcqP0KaK=dABiTXA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 17, 2012 at 01:59:39PM -0400, Sasha Levin wrote:
> On Wed, Jul 18, 2012 at 1:39 PM, J. Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> wrote:
> > On Tue, Jul 17, 2012 at 12:01:26AM +0200, Sasha Levin wrote:
> >> The buffer size in read_flush() is too small for the longest possible values
> >> for it. This can lead to a kernel stack corruption:
> >
> > Thanks!
> 
> I've just stumbled on this crash again, and noticed that this patch
> never made it in.
> 
> Was it just a mixup, or is something still missing?

Oh, man, I guess I got distracted by the subsequent base10len()
discussion.

Added to my for-3.7 branch, I'll push that out after some tests and
hopefully send in a pull request tomorrow.

Thanks for noticing the ommission.

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
