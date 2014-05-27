From: Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>
Subject: Re: [PATCH net-next 8/8] net: cdc_ncm: document the sysfs API
Date: Tue, 27 May 2014 12:40:43 +0200
Message-ID: <20140527104043.3456.qmail@stuge.se>
References: <1401101625-12342-1-git-send-email-bjorn@mork.no> <1401101625-12342-9-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	Lars Melin <larsm17-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
To: =?utf-8?B?QmrDuHJu?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1401101625-12342-9-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bj=C3=B8rn Mork wrote:
> +++ b/Documentation/ABI/testing/sysfs-class-net-cdc_ncm
> @@ -0,0 +1,143 @@
> +What:		/sys/class/net/<iface>/cdc_ncm/min_tx_pkt
> +Date:		May 2014
> +KernelVersion:	3.16
> +Contact:	Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> +Description:
> +		The driver will pad frames longer than this to tx_max,
                                           ^^^^^^
longer or shorter?


> +What:		/sys/class/net/<iface>/cdc_ncm/rx_max
> +Date:		May 2014
> +KernelVersion:	3.16
> +Contact:	Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> +Description:
> +		The maximum NCM Transfer Block (NTB) size for RX.
> +		Cannot exceed the maximum value supported by the
> +		device. Must allow at least one max sized datagram
> +		plus headers.
> +
> +		The actual limits are device dependent.  See
> +		dwNtbInMaxSize.
> +
> +		Note: Some devices will silently ignore changes to
> +		this value, resulting in oversized NTBs and
> +		corresponding framing errors.

That behavior makes the setting only so-so useful. Could the driver
know which devices do this, or is it inconsistent even across
individual devices which are otherwise indistinguishable?


> +What:		/sys/class/net/<iface>/cdc_ncm/tx_timer_usecs
> +Date:		May 2014
> +KernelVersion:	3.16
> +Contact:	Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> +Description:
> +		Datagram aggregation timeout in =C2=B5s. The driver will
> +		wait up to 3 times this timeout for more datagrams to
> +		aggregate before transmitting a NTB frame.
                                              ^
"an NTB frame" might be better since N sounds like "enn".




> +
> +		Valid range: 5 to 4000000
> +
> +		Set to 0 to disable aggregation.
> +
> +The following read only attributes all represent fields of the

read-only?


//Peter
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
