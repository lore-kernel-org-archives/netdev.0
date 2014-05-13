From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH net-next 01/11] net: cdc_ncm: split out rx_max/tx_max
 update of setup
Date: Tue, 13 May 2014 13:07:59 +0200
Message-ID: <1399979279.8278.14.camel@linux-fkkt.site>
References: <1399736509-1159-1-git-send-email-bjorn@mork.no>
	 <1399736509-1159-2-git-send-email-bjorn@mork.no>
	 <1399968546.8278.2.camel@linux-fkkt.site> <871tvy2hcp.fsf@nemi.mork.no>
	 <1399972165.8278.11.camel@linux-fkkt.site> <87sioe114n.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52116 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759006AbaEMLIB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2014 07:08:01 -0400
In-Reply-To: <87sioe114n.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-13 at 11:25 +0200, Bj=C3=B8rn Mork wrote:
> Oliver Neukum <oneukum@suse.de> writes:

> Yes, I agree.  Will change this. Let's try to go for b) then. I.e.
>=20
>  	min =3D USB_CDC_NCM_NTB_MIN_IN_SIZE;
>  	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_RX, le32_to_cpu(ctx->ncm_pa=
rm.dwNtbInMaxSize));
>         if (max < min)
>               max =3D min;

Thanks

	Regards
		Oliver
