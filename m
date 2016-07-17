From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] rndis_host: Set random MAC for ZTE MF910
Date: Sat, 16 Jul 2016 20:02:48 -0700 (PDT)
Message-ID: <20160716.200248.806604407055802626.davem@davemloft.net>
References: <87k2gpnpo5.fsf@miraculix.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D5F4F921C@AcuExch.aculab.com>
	<877fcmlrwb.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org, kristian.evensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <877fcmlrwb.fsf-3F4PFWf5pNjpjLOzFPqGjWGXanvQGlWp@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Fri, 15 Jul 2016 19:42:28 +0200

> David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org> writes:
>> From: Bj=F8rn Mork
>> Not only that, there certainly used to be manufacturers that used 'l=
ocally
>> administered' addresses on all their cards (as well as those that us=
ed unallocated
>> address blocks).
>=20
> Sure. But is there any reason to care about those addresses?

And for that case, this patch we are discussing would be a bug fix.

I'm going to apply the "bp[0] & 0x02" patch.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
