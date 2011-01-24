From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v4] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Mon, 24 Jan 2011 16:07:05 +0800
Message-ID: <AANLkTim-u1V3-uPGrKLuG4SSQMY8HGrEThivgYA7XDeJ@mail.gmail.com>
References: <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
 <1295596533-1748-1-git-send-email-ratbert.chuang@gmail.com> <1295600887.2601.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, Po-Yu Chuang <ratbert@faraday-tech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295600887.2601.5.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Eric,

On Fri, Jan 21, 2011 at 5:08 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 21 janvier 2011 =C3=A0 15:55 +0800, Po-Yu Chuang a =C3=A9=
crit :
> ...
>> +
>> + =C2=A0 =C2=A0 dma_unmap_single(priv->dev, map, skb_headlen(skb), D=
MA_TO_DEVICE);
>> +
>> + =C2=A0 =C2=A0 dev_kfree_skb_irq(skb);
>> +
>> + =C2=A0 =C2=A0 ftmac100_txdes_reset(txdes);
>> +
>> + =C2=A0 =C2=A0 ftmac100_tx_clean_pointer_advance(priv);
>> +
>> + =C2=A0 =C2=A0 priv->tx_pending--;
>> + =C2=A0 =C2=A0 netif_wake_queue(netdev);
>> +
>> + =C2=A0 =C2=A0 return true;
>> +}
>> +
>
> Thanks to NAPI, you can free skb directly, not queuing it via
> NET_TX_SOFTIRQ softirq, using dev_kfree_skb() instead of
> dev_kfree_skb_irq()

=46ixed. Thanks a lot.

best regards,
Po-Yu Chuang
