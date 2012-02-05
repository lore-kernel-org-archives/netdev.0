From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] l2cap_chan_connect() shouldn't be inlined
Date: Sun, 05 Feb 2012 11:12:10 -0800
Message-ID: <1328469130.2062.77.camel@aeonflux>
References: <20120205062105.GZ23916@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120205062105.GZ23916-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Al,

> For one thing, it's big.  For another, the only caller is in a different
> file anyway...
> 
> Signed-off-by: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
> 
> diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
> index 68f5891..124f7cf 100644
> --- a/include/net/bluetooth/l2cap.h
> +++ b/include/net/bluetooth/l2cap.h
> @@ -834,7 +834,7 @@ int l2cap_add_scid(struct l2cap_chan *chan,  __u16 scid);
>  struct l2cap_chan *l2cap_chan_create(struct sock *sk);
>  void l2cap_chan_close(struct l2cap_chan *chan, int reason);
>  void l2cap_chan_destroy(struct l2cap_chan *chan);
> -inline int l2cap_chan_connect(struct l2cap_chan *chan, __le16 psm, u16 cid,
> +int l2cap_chan_connect(struct l2cap_chan *chan, __le16 psm, u16 cid,
>  								bdaddr_t *dst);

I have no idea on how that happened, but you are fully correct this is
pointless.

Acked-by: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>

Regards

Marcel
