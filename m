From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] SUNRPC: Prevent kernel stack corruption on long values of flush
Date: Wed, 17 Oct 2012 13:59:39 -0400
Message-ID: <CA+1xoqcgWTP8pAY3Ok2R0JM-ZXSkGroEvAFcqP0KaK=dABiTXA@mail.gmail.com>
References: <1342476086-21638-1-git-send-email-levinsasha928@gmail.com> <20120718173913.GA1298@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120718173913.GA1298-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 18, 2012 at 1:39 PM, J. Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> wrote:
> On Tue, Jul 17, 2012 at 12:01:26AM +0200, Sasha Levin wrote:
>> The buffer size in read_flush() is too small for the longest possible values
>> for it. This can lead to a kernel stack corruption:
>
> Thanks!

I've just stumbled on this crash again, and noticed that this patch
never made it in.

Was it just a mixup, or is something still missing?


Thanks,
Sasha
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
