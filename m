From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 8/27] wireless: cw1200: Use setup_timer
Date: Wed, 07 Jan 2015 19:53:57 +0200
Message-ID: <87fvbmqxxm.fsf@kamboji.qca.qualcomm.com>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
	<1419604558-29743-7-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Solomon Peachy <pizza-pCgMCH4qpMRg9hUCZPvPmw@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1419604558-29743-7-git-send-email-Julia.Lawall-L2FTfq7BK8M@public.gmane.org> (Julia
	Lawall's message of "Fri, 26 Dec 2014 15:35:37 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org> writes:

> Convert a call to init_timer and accompanying intializations of
> the timer's data and function fields to a call to setup_timer.
>
> A simplified version of the semantic match that fixes this problem is as
> follows: (http://coccinelle.lip6.fr/)
>
> // <smpl>
> @@
> expression t,f,d;
> @@
>
> -init_timer(&t);
> +setup_timer(&t,f,d);
> -t.data = d;
> -t.function = f;
> // </smpl>
>
> Signed-off-by: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>

Thanks, I applied the wireless-drivers patches below to
wireless-drivers-next.git.

e4a1c3f88e65 mwifiex: 11n_rxreorder: Use setup_timer
c6c33e772407 mwifiex: main: Use setup_timer
99a1b74395a5 orinoco_usb: Use setup_timer
1a94ace406ad iwl3945: Use setup_timer
af68b87f7211 iwl4965: Use setup_timer
0be01bf29721 cw1200: queue: Use setup_timer
dabefea6937d cw1200: main: Use setup_timer
983988ec0a24 wireless: cw1200: Use setup_timer

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
