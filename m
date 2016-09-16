From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: cdc_ncm driver padding problem
Date: Fri, 16 Sep 2016 08:33:37 +0200
Message-ID: <87h99guzem.fsf@miraculix.mork.no>
References: <57D41536.2090102@gmail.com> <57D437E4.2000708@gmail.com>
        <alpine.LNX.2.20.1609111517350.30036@localhost.localdomain>
        <15569aad-22e2-aa4d-e7f1-832063c6490a@gmail.com>
        <alpine.LNX.2.20.1609160141270.19559@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Marek Brudka <mbrudka-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.20.1609160141270.19559-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
        (Enrico Mioso's message of "Fri, 16 Sep 2016 01:46:25 +0200 (CEST)")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> =3D=3DFrom: Marek Brudka <mbrudka-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
..
> =3D=3DThe bad thing is DHCP. It seems, that cdc_ncm driver somehow consum=
es DHCP
> =3D=3Dreplies. I had to manually setup wwan0 interface as well as routing
> =3D=3Dusing the result
> =3D=3Dof Hayes command
> =3D=3D
> =3D=3DAT^DHCP?
> =3D=3D^DHCP:
> =3D=3DEC684764,F8FFFFFF,E9684764,E9684764,356002D4,366002D4,43200000,4320=
0000
> =3D=3DOK


Are we sure that this firmware supports DHCP?  It's not uncommon for
modem firmwares to lack such support, and I find this a much more likely
explanation than the driver somehow messing up the DHCP replies while
letting other packets through.

Unfortunately there is no easy way to tell for sure if a specific
feature is enabled or not in a specific firmware.  Is it possible to get
a snoop from Windows while connecting, using the modem in the same mode?
That would tell us whether the Windows software depends on DHCP or is
using the AT^DHCP command.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
