From: Rami Rosen <roszenrami-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 01/10] ethernet: add sun8i-emac driver
Date: Sun, 23 Oct 2016 15:08:56 +0300
Message-ID: <CAKoUAr=HmzYHq53i1bAzgOYd8RNzO_xBi30HW41KVZ=W4-Pdvg@mail.gmail.com>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com> <1475828757-926-2-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, andrew-g2DYL2Zd6BY@public.gmane.org,
        Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475828757-926-2-git-send-email-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Corentin,


Trivial comment: rx_saf_fai and rx_daf_fail are not used. This implies that also
rx_saf_error and rx_daf_error should be removed:

> +static const char const estats_str[][ETH_GSTRING_LEN] = {
...
> +       "rx_header_error",
> +       "rx_overflow_error",
> +       "rx_saf_error",
> +       "rx_daf_error",
> +       "rx_buf_error",
...

> +
> +struct sun8i_emac_stats {
> +       u64 rx_payload_error;
...
> +       u64 rx_overflow_error;
> +       u64 rx_saf_fail;
> +       u64 rx_daf_fail;

> +       u64 tx_used_desc;
> +       u64 napi_schedule;
> +       u64 napi_underflow;
> +};
> +

Trivial: typo, should be: can transfer

> +/* The datasheet said that each descriptor can transfers up to 4096bytes
> + * But latter, a register documentation reduce that value to 2048

Regards,
Rami Rosen
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
