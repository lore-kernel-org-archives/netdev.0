From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] wlcore: spi: add wl18xx support
Date: Thu, 07 Apr 2016 17:32:08 +0300
Message-ID: <87wpo97amv.fsf@kamboji.qca.qualcomm.com>
References: <1459343218-24536-1-git-send-email-eyalr@ti.com>
	<87shyx38tz.fsf@purkki.adurom.net>
	<8665E2433BC68541A24DFFCA87B70F5B360B5430@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eyal Reizer <eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-wireless\@vger.kernel.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree\@vger.kernel.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Reizer\, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8665E2433BC68541A24DFFCA87B70F5B360B5430-1tpBd5JUCm6IQmiDNMet8wC/G2K4zDHf@public.gmane.org>
	(Eyal Reizer's message of "Thu, 7 Apr 2016 12:45:13 +0000")
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

"Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org> writes:

>> >  static const struct of_device_id wlcore_spi_of_match_table[] = {
>> > -	{ .compatible = "ti,wl1271" },
>> > +	{ .compatible = "ti,wl1271", .data = &wl12xx_data},
>> > +	{ .compatible = "ti,wl1273", .data = &wl12xx_data},
>> > +	{ .compatible = "ti,wl1281", .data = &wl12xx_data},
>> > +	{ .compatible = "ti,wl1283", .data = &wl12xx_data},
>> > +	{ .compatible = "ti,wl1801", .data = &wl18xx_data},
>> > +	{ .compatible = "ti,wl1805", .data = &wl18xx_data},
>> > +	{ .compatible = "ti,wl1807", .data = &wl18xx_data},
>> > +	{ .compatible = "ti,wl1831", .data = &wl18xx_data},
>> > +	{ .compatible = "ti,wl1835", .data = &wl18xx_data},
>> > +	{ .compatible = "ti,wl1837", .data = &wl18xx_data},
>> >  	{ }
>> 
>> Shouldn't you also update bindings/net/wireless/ti,wlcore,spi.txt? Now it only
>> mentions about ti,wl1271 and not anything about the rest.
>
> You are right! Will be fixed in v2

Thanks. Also remember to CC devicetree list.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
