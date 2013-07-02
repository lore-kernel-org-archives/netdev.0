From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] net: cdc_ether: allow combined control and data
 interface
Date: Mon, 01 Jul 2013 23:38:17 -0700 (PDT)
Message-ID: <20130701.233817.1253947554176449518.davem@davemloft.net>
References: <1372500186-23567-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1372500186-23567-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Sat, 29 Jun 2013 12:03:06 +0200

> Some Icera based Huawei modems handled by this driver are not
> completely CDC ECM compliant, using the same USB interface for both
> control and data. The CDC functional descriptors include a Union
> naming this interface as both master and slave, so it is supportable
> by relaxing the descriptor parsing in case these interfaces are
> identical.
>=20
> This has been tested on a Huawei K3806 and verified to add support
> for that device.
>=20
> Reported-and-tested-by: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> ---
> v2: Simplified unbind logic.  Thanks to Oliver Neukum

Oliver if you could give this a quick review, that would be
great.

Thanks.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
