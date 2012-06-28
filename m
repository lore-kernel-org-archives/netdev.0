From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] net: nfc: fix panic in accept()
Date: Thu, 28 Jun 2012 09:42:54 -0400
Message-ID: <20120628134254.GB2115@tuxdriver.com>
References: <20120611145700.GY22557@sortiz-mobl>
 <1339426778.6001.2312.camel@edumazet-glaptop>
 <20120611152007.GZ22557@sortiz-mobl>
 <1339433810.4999.65.camel@lappy>
 <20120611172545.GA1776@redhat.com>
 <CA+1xoqcwr-5dzHvqkt9x0-xj9EFAywVfva=asbHXvX-LSBWqdA@mail.gmail.com>
 <1340639612.10893.84.camel@edumazet-glaptop>
 <20120625171532.GB16275@sortiz-mobl>
 <CA+1xoqfy21wOh2myV0D6iBDqoZ3YmkwNZwKBVXLU75zePOGi4w@mail.gmail.com>
 <20120628125612.GG4846@sortiz-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org, aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120628125612.GG4846@sortiz-mobl>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 28, 2012 at 02:56:12PM +0200, Samuel Ortiz wrote:
> Hi Sasha,
> 
> On Thu, Jun 28, 2012 at 02:11:38PM +0200, Sasha Levin wrote:
> > Hi Samuel,
> > 
> > On Mon, Jun 25, 2012 at 7:15 PM, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
> > > Hi Eric,
> > >
> > > On Mon, Jun 25, 2012 at 05:53:32PM +0200, Eric Dumazet wrote:
> > >> From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> > >>
> > >> Sasha Levin reported following panic :
> > > I applied a similar patch, more consistent with the rest of the NFC socket
> > > code, still with you as the author. See here:
> > >
> > > http://git.kernel.org/?p=linux/kernel/git/sameo/nfc-3.0.git;a=commit;h=631c301f20558525a641fadffc0126affd3dc4a4
> > 
> > Could this tree be included in -next please?
> No, wireless-next is already included in -next. The above patch is making its
> way upstream, it's in the wireless.git tree and should hit davem's net tree
> soon.

FWIW, lots (or most?) of the bug fix trees get pulled into -next
as well.  Having the nfc tree go there makes sense to me.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
