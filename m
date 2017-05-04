From: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Thu, 4 May 2017 18:30:27 +0000
Message-ID: <1493922625.2692.8.camel@sandisk.com>
References: <20170504180216.7665-1-leon@kernel.org>
         <1493921453.2692.6.camel@sandisk.com>
         <20170504182542.GD22833@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org" <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org" <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        "ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org" <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        "stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170504182542.GD22833-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Content-Language: en-US
Content-ID: <7201FA4E3F209A4A89B8DBF3FC36DCF2-+cFlbfsKLD6cE4WynfumptQqCkab/8FMAL8bYrjMMd8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-05-04 at 21:25 +0300, Leon Romanovsky wrote:
> On Thu, May 04, 2017 at 06:10:54PM +0000, Bart Van Assche wrote:
> > On Thu, 2017-05-04 at 21:02 +0300, Leon Romanovsky wrote:
> > > Following our discussion both in mailing list [1] and at the LPC 2016=
 [2],
> > > we would like to propose this RDMA tool to be part of iproute2 packag=
e
> > > and finally improve this situation.
> >=20
> > Hello Leon,
> >=20
> > Although I really appreciate your work: can you clarify why you would l=
ike to
> > add *RDMA* functionality to an *IP routing* tool? I haven't found any m=
otivation
> > for adding RDMA functionality to iproute2 in [1].
>=20
> We are planning to reuse the same infrastructure provided by iproute2,
> like netlink parsing, access to distributions, same CLI and same standard=
s.
>=20
> Right now, RDMA is already tightened to netdev: iWARP, RoCE, IPoIB, HFI-V=
NIC.
> Many drivers (mlx, qed, i40, cxgb) are sharing code between net and
> RDMA.
>=20
> I do expect that iproute2 will be installed on every machine with any
> type of connection, including IB and OPA.
>=20
> So I think that it is enough to be part of that suite and don't invent
> our own for one specific tool.

Hello Leon,

Sorry but to me that sounds like a weak argument for including RDMA functio=
nality
in iproute2. There is already a library for communication over netlink sock=
ets,
namely libnl. Is there functionality that is in iproute2 but not in libnl a=
nd
that is needed for the new tool? If so, have you considered to create a new
library for that functionality?

Thanks,

Bart.=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
