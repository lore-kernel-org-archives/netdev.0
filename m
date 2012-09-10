From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Regression associated with commit c8628155ece3 - "tcp: reduce
 out_of_order memory use"
Date: Mon, 10 Sep 2012 17:04:06 +0200
Message-ID: <1347289446.1234.1717.camel@edumazet-glaptop>
References: <50369925.3050705@lwfinger.net>
	 <1345757200.5904.1890.camel@edumazet-glaptop> <50378B35.80307@lwfinger.net>
	 <20120824.111948.680531915905273128.davem@davemloft.net>
	 <5037A4B0.3080208@lwfinger.net>
	 <1345825095.19483.19.camel@edumazet-glaptop>
	 <1345825432.19483.20.camel@edumazet-glaptop> <5037B2AC.50704@lwfinger.net>
	 <1345830424.19483.69.camel@edumazet-glaptop>
	 <503BB49C.5010402@lwfinger.net>
	 <1347266366.1234.1267.camel@edumazet-glaptop>
	 <504DFEFF.6060004@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <504DFEFF.6060004-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-09-10 at 09:53 -0500, Larry Finger wrote:

> Eric,
> 
> What is the md5sum for the firmware file /lib/firmware/rtlwifi/rtl8712u.bin? 
> Over the weekend, there was a report of another device that had problems with 
> firmware that was added to the linux-firmware repo in July with md5sum of 
> c6f3b7b880aefb7b3f249428d659bdbb. An older version with md5sum of 
> 200fd952db3cc9259b1fd05e3e51966f works in that case. I'll send you this one 
> privately.
> 
> I have a Netgear WNDR3300 and also get the addbareq events, but I do not get 
> freezes. I'm not sure the message is correlated.
> 

It seems I have the c6f3b7b880aefb7b3f249428d659bdbb one
# md5sum /data/src/linux-firmware/rtlwifi/rtl8712u.bin /lib/firmware/rtlwifi/rtl8712u.bin
c6f3b7b880aefb7b3f249428d659bdbb  /data/src/linux-firmware/rtlwifi/rtl8712u.bin
c6f3b7b880aefb7b3f249428d659bdbb  /lib/firmware/rtlwifi/rtl8712u.bin

Since I have linux-firmware tree, should I go back to initial commit 
commit 8f919160792e4702c6b7a67a243cea4f757407e4
Author: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date:   Mon Nov 1 23:56:52 2010 -0500

    linux-firmware: Add firmware files for Realtek RTL8712U and
RTL8192CE

Thanks !



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
