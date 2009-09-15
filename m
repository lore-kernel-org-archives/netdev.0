From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: alloc skb based on a given data buffer
Date: Tue, 15 Sep 2009 14:16:06 -0700 (PDT)
Message-ID: <20090915.141606.134994761.davem@davemloft.net>
References: <20090915.020903.93643290.davem@davemloft.net>
	<1253006111.7549.61.camel@debian>
	<1253028631.23427.55.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org, reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, assaf.krauss-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	mohamed.abbas-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1253028631.23427.55.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Tue, 15 Sep 2009 08:30:31 -0700

> Hold, mac80211 can't cope with that at this point for sw crypto and
> possibly other things.

Then it should skb_linearize() at input, or similar.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
