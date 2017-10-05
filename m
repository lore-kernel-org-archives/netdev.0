From: Rodney Cummings <rodney.cummings@ni.com>
Subject: RE: [next-queue PATCH v4 3/4] net/sched: Introduce Credit Based
 Shaper (CBS) qdisc
Date: Thu, 5 Oct 2017 19:17:03 +0000
Message-ID: <CY1PR0401MB153671C2B94D23793C78B2BE92700@CY1PR0401MB1536.namprd04.prod.outlook.com>
References: <CAEYbN3RjUXGMyxo0t88-ASNVEVQdfXkMzBbMtMHAhqWScOO=Cg@mail.gmail.com>
        <20171005.112909.2052593524154643514.davem@davemloft.net>
        <CY1PR0401MB1536A44D0AB459BB9618664A92700@CY1PR0401MB1536.namprd04.prod.outlook.com>
 <20171005.120508.2267452751875787466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "levipearson@gmail.com" <levipearson@gmail.com>,
        "jiri@resnulli.us" <jiri@resnulli.us>,
        "vinicius.gomes@intel.com" <vinicius.gomes@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "andre.guedes@intel.com" <andre.guedes@intel.com>,
        "ivan.briano@intel.com" <ivan.briano@intel.com>,
        "jesus.sanchez-palencia@intel.com" <jesus.sanchez-palencia@intel.com>,
        "boon.leong.ong@intel.com" <boon.leong.ong@intel.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>,
        "henrik@austad.us" <henrik@austad.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00010702.pphosted.com ([148.163.156.75]:32950 "EHLO
        mx0b-00010702.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751823AbdJETRZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 15:17:25 -0400
In-Reply-To: <20171005.120508.2267452751875787466.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No excuse. If the software cannot meet the standard's requirements, it is n=
on-conformant,
which means it cannot be called a standard credit-based shaper.

But... I have no objection if someone wants to try software-only. I'm just =
saying that it
is a waste of time for me.

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, October 5, 2017 2:05 PM
> To: Rodney Cummings <rodney.cummings@ni.com>
> Cc: levipearson@gmail.com; jiri@resnulli.us; vinicius.gomes@intel.com;
> netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org;
> jhs@mojatatu.com; xiyou.wangcong@gmail.com; andre.guedes@intel.com;
> ivan.briano@intel.com; jesus.sanchez-palencia@intel.com;
> boon.leong.ong@intel.com; richardcochran@gmail.com; henrik@austad.us
> Subject: Re: [next-queue PATCH v4 3/4] net/sched: Introduce Credit Based
> Shaper (CBS) qdisc
>=20
> From: Rodney Cummings <rodney.cummings@ni.com>
> Date: Thu, 5 Oct 2017 18:41:48 +0000
>=20
> > The IEEE Std 802.1Q specs for credit-based shaper require precise
> transmit decisions
> > within a 125 microsecond window of time.
> >
> > Even with the Preempt RT patch or similar enhancements, that isn't very
> practical
> > as software-only. I doubt that software would conform to the standard's
> > requirements.
> >
> > This is analogous to memory, or CPU.
>=20
> I feel like this is looking for an excuse to not have to at least try to
> implement
> the software version of CBS.
