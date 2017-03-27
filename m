From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [net-next 05/11] i40e: fix for queue timing delays
Date: Mon, 27 Mar 2017 16:12:37 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B626503F4598@ORSMSX102.amr.corp.intel.com>
References: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
        <20170325081305.31835-6-jeffrey.t.kirsher@intel.com>
 <20170325.200045.766752589165691684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: David Miller <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3544 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751574AbdC0QNb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 12:13:31 -0400
In-Reply-To: <20170325.200045.766752589165691684.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, March 25, 2017 8:01 PM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: Wyborny, Carolyn <carolyn.wyborny@intel.com>;
> netdev@vger.kernel.org; nhorman@redhat.com; sassmann@redhat.com;
> jogreene@redhat.com
> Subject: Re: [net-next 05/11] i40e: fix for queue timing delays
>=20
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sat, 25 Mar 2017 01:12:59 -0700
>=20
> > From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> >
> > This patch adds a delay to Rx queue disables to accommodate HW needs.
> >
[..]
> > +	/* HW needs up to 50ms to finish RX queue disable*/
> > +	mdelay(50);
>=20
> You just polled a register which indicates that the request is finished.
> Needing futher time for the operation to complete doesn't make any
> sense.
>=20
> If this is really needed, you need to explain in the commit message, in
> detail, what is really the problem here.
>=20
> THanks.

It's a hw limitation, will submit an updated patch with more detail.

Thanks,

Carolyn

Carolyn Wyborny=20
Linux Development=20
Networking Division=20
Intel Corporation=20
