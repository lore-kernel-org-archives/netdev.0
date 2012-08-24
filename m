From: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH] mwifiex: use is_zero_ether_addr() instead of memcmp()
Date: Thu, 23 Aug 2012 20:30:54 -0700
Message-ID: <477F20668A386D41ADCC57781B1F7043083B0BBB71@SC-VEXCH1.marvell.com>
References: <CAPgLHd--KY+zNjUwOHKgEJuTfJuoA=7vKR3JMBUgUc+BtjC9Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org" <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAPgLHd--KY+zNjUwOHKgEJuTfJuoA=7vKR3JMBUgUc+BtjC9Ng-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > Apparently there are two more occurrences of zero_mac (scan.c:843)
> 
> This is part is special:
> 
> memcmp(scan_cfg_out->specific_bssid, &zero_mac, sizeof(zero_mac)))
> 
> &zero_mac equal zero_mac, but it missing to spatch.

I will take care of this then.

Thanks,
Bing

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
