From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC] net: cdc_ncm, cdc_mbim: allow user to prefer NCM for backwards compatibility
Date: Wed, 13 Mar 2013 17:55:55 +0100
Message-ID: <87k3pb6xyc.fsf@nemi.mork.no>
References: <87sj43cxg5.fsf@nemi.mork.no>
	<1362939209-19056-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@stericsson.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Greg Suarez <gsuarez@smithmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44416 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932984Ab3CMQ4I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 12:56:08 -0400
In-Reply-To: <1362939209-19056-1-git-send-email-bjorn@mork.no>
 (=?utf-8?Q?=22Bj=C3=B8rn?= Mork"'s
	message of "Sun, 10 Mar 2013 19:13:29 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

> +#if IS_ENABLED(CONFIG_USB_NET_CDC_MBIM)
> +static bool prefer_mbim =3D true;
> +#else
> +static bool prefer_mbim;
> +#endif
> +module_param(prefer_mbim, bool, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(prefer_mbim, "Prefer MBIM on NCM/MBIM backwards com=
patible functions");

So, noone wanting to comment on this? I am not sure how to interpret
that.  If I liked the solution myself I would just have taken it as an
unanimous ack, but I don't...

Please, if your gut feeling is that this is the most stupid thing you'v=
e
ever seen, then just say so.  I can take it :)


Bj=C3=B8rn
