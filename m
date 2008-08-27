From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Wed, 27 Aug 2008 10:38:56 +0300
Message-ID: <1ba2fa240808270038r24d5eeb9l36fd70ef5ae904f5@mail.gmail.com>
References: <20080827013009.GA15781@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080827013009.GA15781-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 27, 2008 at 4:30 AM, John W. Linville
<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> Dave,
>
> Here is the latest round of fixes intended for 2.6.27.  I think
> the non-iwlwifi ones are pretty solid.  As for the iwlwifi ones,
> the Intel guys assure me that these are important changes.
>
> You will notice that (despite my exhortations) no less than two of
> the iwlwifi patches declare themselves as cleanups.  I have included
> them anyway because the later fixes depend on them and they seemed
> harmless enough.  Plus, they were posted (or at least written) before
> the recent fireworks about what we should be merging after -rc1...
>
PCI cleanup patch is badly named. It fixes PCI registers sizes and ads
one forgotten hw workaround
I called it cleanup because it went through all PCI accesses we have
in the driver.

Scan cleanup was requested because of dependencies but it's harmless,
we can rebase the patches
prefer not it's just waste of time. Afther massive ath9k merge I
didn't see it was a conceptual problem.

Thanks
Tomas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
