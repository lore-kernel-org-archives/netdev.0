From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH 3/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 16:33:54 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6EB5@saturn3.aculab.com>
References: <CAL1RGDWnc478=ToFQEC51Usn6LLZgLen=CymFZ0C0GnRp9BAsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Roland Dreier" <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <parav.pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <CAL1RGDWnc478=ToFQEC51Usn6LLZgLen=CymFZ0C0GnRp9BAsw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=20
> > +#define is_cqe_wr_imm(cqe) \
> > + =A0 =A0 =A0 ((le32_to_cpu(cqe->flags_status_srcqpn) & OCRDMA_CQE_=
WRITE_IMM) ? 1 : 0)
>=20
> ...similar comment about using readable typesafe inline functions
> instead of macros...

and if you are using #defines, you need to enclose every reference
to the parameters in ().

	David


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
