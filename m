From: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
Subject: Re: [PATCH 0/10] use safer test on the result of
 find_first_zero_bit
Date: Wed, 4 Jun 2014 11:38:13 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1406041137270.2441@hadrien>
References: <1401872880-23685-1-git-send-email-Julia.Lawall@lip6.fr> <CAMuHMdXsoFUXj4jLMWN6NY7Um19KwWO9Rhx=9=gqWu_K5Ev2kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Fbdev development list <linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux-sh list <linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	driverdevel <devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org>, iss_storagedev-VXdhtT5mjnY@public.gmane.org,
	scsi <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-s390 <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMuHMdXsoFUXj4jLMWN6NY7Um19KwWO9Rhx=9=gqWu_K5Ev2kQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Wed, 4 Jun 2014, Geert Uytterhoeven wrote:

> Hi Julia,
>
> On Wed, Jun 4, 2014 at 11:07 AM, Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org> wrote:
> > Find_first_zero_bit considers BITS_PER_LONG bits at a time, and thus may
> > return a larger number than the maximum position argument if that position
> > is not a multiple of BITS_PER_LONG.
>
> Shouldn't this be fixed in find_first_zero_bit() instead?

OK, I could do that as well.  Most of the callers currently test with >=.
Should they be left as is, or changed to use ==?

julia
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
