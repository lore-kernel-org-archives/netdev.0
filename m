From: Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware restart.
Date: Sun, 21 Sep 2008 23:45:06 +0100
Message-ID: <20080921224506.GB24461@srcf.ucam.org>
References: <20080921172316.GA6306@2ka.mipt.ru> <1222025731.6782.117.camel@californication>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Marcel Holtmann <holtmann-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1222025731.6782.117.camel@californication>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 21, 2008 at 09:35:31PM +0200, Marcel Holtmann wrote:

> I don't know if it is for this bug or a different one, but Matthew
> Garrett seem to have some pending patches. At least that is what he told
> me at PlumbersConf. Lets see if these patches do help. And please follow
> up with Arjan's suggestion and put a WARN_ON in the upstream code
> instead of waving CONFIG_BROKEN around.

The fix I had for this was actually for ipw2200, but it ought to be 
applicable for 2100 as well. The ideal fix is probably to ensure that 
ipw*_down D3s the card and *_up D0s it, which brings enhanced runtime 
power saving and also has the nice side effect of actually resetting the 
damned POS in error cases.

-- 
Matthew Garrett | mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
