From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/3] cw1200: Don't leak memory if krealloc failes
Date: Fri, 30 Sep 2016 14:29:39 +0200
Message-ID: <1475238579.17481.56.camel@sipsolutions.net>
References: <1475237495-15030-1-git-send-email-jthumshirn@suse.de>
         (sfid-20160930_141208_240938_8F56ACB3)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Thumshirn <jthumshirn-l3A5Bk7waGM@public.gmane.org>,
        Solomon Peachy <pizza-pCgMCH4qpMRg9hUCZPvPmw@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475237495-15030-1-git-send-email-jthumshirn-l3A5Bk7waGM@public.gmane.org> (sfid-20160930_141208_240938_8F56ACB3)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> +	tmp = krealloc(buf->begin, size, GFP_KERNEL | GFP_DMA);
> +	if (tmp) {
> 
I think that check is inverted?

johannes
