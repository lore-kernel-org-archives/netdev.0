From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: [PATCH 10/14] SIWv2: Transmit path: siw_qp_tx.c
Date: Mon, 20 Jun 2011 18:32:13 +0200
Message-ID: <BANLkTi=K2MfHyFmoSSwbduWvAQwwDVXGHQ@mail.gmail.com>
References: <BANLkTimSqwBK_pEGsydCAEvO=S6WVVzDPQ@mail.gmail.com> <OF564FAAA3.FC8A4AB9-ONC12578B5.003C1E38-C12578B5.0044F0C1@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <OF564FAAA3.FC8A4AB9-ONC12578B5.003C1E38-C12578B5.0044F0C1-Xeyd2O9EBijQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 20, 2011 at 2:33 PM, Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org> w=
rote:
> bart.vanassche-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote on 06/18/2011 07:47:29 PM:
> > On Thu, Jun 16, 2011 at 2:42 PM, Bernard Metzler <bmt-OA+xvbQnYDG0NRUx5Wjc1Q@public.gmane.org=
m>
> wrote:
> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tx_type =3D=3D RDMAP_RDMA_READ_=
REQ) {
> >
> > This is what the compiler says about the above statement:
> >
> > drivers/infiniband/hw/siw/siw_qp_tx.c:1145:15: warning: comparison
> > between enum siw_wr_opcode and enum rdma_opcode
> >
> > So how can that statement be correct ?
> >
> it will not - must be changed to 'SIW_WR_RDMA_READ_REQ'...many thanks=
!
> I obviously used sparse in a wrong way:
> building within kernel tree with 'make C=3D1 CF=3D"-Wsparse-all' does=
 not give
> me the indicated warning (neither does setting CF=3D"-Wenum-mismatch"=
).

That warning was not reported by sparse but by gcc 4.5.

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
