From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] mac80211: fix compilation warning
Date: Tue, 14 Sep 2010 06:09:48 +0000
Message-ID: <20100914060948.GA6908@ff.dom.local>
References: <1284441432.3704.0.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, Jouni Malinen <j@w1.fi>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1284441432.3704.0.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2010-09-14 07:17, Johannes Berg wrote:
> On Sun, 2010-09-12 at 14:10 +0300, Felipe Contreras wrote:
> 
>>  	struct ieee80211_hdr hdr;
>> -	struct ieee80211s_hdr mesh_hdr;
>>  	const u8 *encaps_data;
>>  	int encaps_len, skip_header_bytes;
>>  	int nh_pos, h_pos;
>> @@ -1755,7 +1754,9 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
>>  		hdrlen = 30;
>>  		break;
>>  #ifdef CONFIG_MAC80211_MESH
>> -	case NL80211_IFTYPE_MESH_POINT:
>> +	case NL80211_IFTYPE_MESH_POINT: {
>> +		struct ieee80211s_hdr mesh_hdr;
>> +
> 
> ...
> 
> might be nicer to just add __maybe_unused.
> 
> johannes
> 

Or at least more consistent with the fix in net-next ;-)

Jarek P.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
