From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net,stable] net: cdc_mbim: add "NDP to end" quirk for
 Huawei E3372
Date: Sat, 05 Dec 2015 23:36:00 -0500 (EST)
Message-ID: <20151205.233600.318318676015594203.davem@davemloft.net>
References: <1449316910-8009-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	hvtaifwkbgefbaei-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org,
	mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449316910-8009-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Sat,  5 Dec 2015 13:01:50 +0100

> The Huawei E3372 (12d1:157d) needs this quirk in MBIM mode
> as well. Allow this by forcing the NTB to contain only a
> single NDP, and add a device specific entry for this ID.
>=20
> Due to the way Huawei use device IDs, this might be applied
> to other modems as well.  It is assumed that those modems
> will be based on the same firmware and will need this quirk
> too.  If not, it will still not harm normal usage, although
> multiplexing performance could be impacted.
>=20
> Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Reported-by: Sami Farin <hvtaifwkbgefbaei-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied and queued up for -stable, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
