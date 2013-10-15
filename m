From: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [Ilw] drivers/net/wireless/iwlwifi/dvm/tx.c:456
	iwlagn_tx_skb+0x6c5/0x883()
Date: Tue, 15 Oct 2013 10:52:04 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB301DC46E5@HASMSX103.ger.corp.intel.com>
References: <9010061839.20131015123940@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sander Eikelenboom <linux-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Berg, Johannes" <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9010061839.20131015123940-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> 
> Hi,
> 
> I'm having a:
> 
> 02:00.0 Network controller: Intel Corporation Centrino Advanced-N 6235 (rev
> 24)
> 
> And i'm running into this warning on boot with a 3.11.2 and 3.12-rc5 kernel.
> 
> [   23.904950] ------------[ cut here ]------------
> [   23.904957] WARNING: CPU: 0 PID: 2531 at
> drivers/net/wireless/iwlwifi/dvm/tx.c:456 iwlagn_tx_skb+0x6c5/0x883()

Can you reproduce easily?
If yes, please reproduce with debug parameters:
modprobe iwlwifi debug=0xC0800000

Also, please enable MAC80211_HT_DEBUG

Thanks

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
