From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH] eisa: standardize on eisa_register_driver like similar
 bus registrations
Date: Tue, 08 Oct 2013 08:53:18 +0400
Message-ID: <1381207998.7959.1.camel@dabdike>
References: <1381026958-4459-1-git-send-email-tedheadster@gmail.com>
	 <20131007.160225.1679994399484815968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tedheadster@gmail.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20131007.160225.1679994399484815968.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-10-07 at 16:02 -0400, David Miller wrote:
> From: Matthew Whitehead <tedheadster@gmail.com>
> Date: Sat,  5 Oct 2013 22:35:58 -0400
>=20
> > The other buses (isa, pci, pnp, parport, usb, tty, etc) all use the=
 convention
> > of ${BUSNAME}_register_driver. Rewrite the little remaining code th=
at uses EISA
> > to follow this convention for easier readability.
> >=20
> > This affects the EISA bus, SCSI, and networking subsystems so only =
one should
> > ultimately merge the patch if it is accepted.
> >=20
> > Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>
>=20
> I'm fine with someone else taking this, for networking parts:

I don't really see much value in the rename, especially as eisa is
probably not long for this world.  However, its a trivial rename, so
bundle it all up into a single patch and send it to Ji=C5=99=C3=AD Kosi=
na
<trivial@vger.kernel.org> he'll take care of it.

James



--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
