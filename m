From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net/for-next V1 1/1] IB/ipoib: break linkage to neighbouring
 system
Date: Tue, 24 Jul 2012 09:23:25 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1207240922460.29808@router.home>
References: <1342703938-29904-1-git-send-email-ogerlitz@mellanox.com> <1342703938-29904-2-git-send-email-ogerlitz@mellanox.com> <alpine.DEB.2.00.1207190938190.28115@router.home> <50082183.5000402@mellanox.com> <alpine.DEB.2.00.1207191023130.29808@router.home>
 <500833D9.8000001@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Shlomo Pongartz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <500833D9.8000001-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2012, Or Gerlitz wrote:

> > If you have neighbor expiration periods of 4 hrs and it is necessary to
> > run the expiration logic then please expire all the neighbor entries due a
> > certain period after that as well to avoid running the expiration again in
> > the next minute or so.
>
>
> This is still a bit unclear here... do you mean to say that at a certain point
> in time,
> **all** entries need to be deleted irrelevant of their (jiffies) age? why?

No. Just the ones in a certain time frame.
>
> > I guess the fuzz factor needs to scale depending on the expiration period.
> >
> >
>
> and this is what happens now, the factor is 0.5, entry would be deleted when
> if  (60m <= unused < 90s) holds

Ok that sounds good and that is what I meant.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
