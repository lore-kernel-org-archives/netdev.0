From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [net-next 04/14] i40e: dump VF information in debugfs
Date: Thu, 20 Apr 2017 13:57:08 +0000
Message-ID: <BL2PR07MB2306DEC60F085B88BA230C3A8D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
 <20170420015750.6828-5-jeffrey.t.kirsher@intel.com>
 <CAJ3xEMiCuV5A_Ccy7=mKSjc9xxhg4enUxDq-MM-cO3YjSa439A@mail.gmail.com>
 <BL2PR07MB23064C036E994DC63475F7388D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170420113942.GD1886@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0086.outbound.protection.outlook.com ([104.47.33.86]:59968
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1031895AbdDTN5P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 09:57:15 -0400
In-Reply-To: <20170420113942.GD1886@nanopsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> > Dump some internal state about VFs through debugfs. This provides
> >> > information not available with 'ip link show'.
> >>
> >> such as?
> >>
> >> donnwantobethedebugfspolice, but still, in the 2-3 times we tried to
> >> push debugfs to MLNX NIC drivers, Dave disallowed that, and lately
> >> the switch team even went further and deleted that portion of the
> >> mlxsw driver -- all to all,  I don't see much point for these type of =
changes,
> thoughts?
> >
> >Don't want to hikjack your thread, but continuing this topic - Is there
> >some flat-out disapproval for debugfs in net-next now?
>=20
> It was mentioned by DaveM on the list multiple times.

> >
> >We're currently internally engaged with adding qed support for register
> >dumps [~equivalents for `ethtool -d' outputs] through debugfs, on
> >behalf of storage drivers [qedi/qedf] lacking the API for doing that.
>=20
> That sounds wrong. Either introduce a generic infra to expose the info yo=
u
> need or you don't do that.

I agree this surely isn't *our* convention, but for scsi  using debugfs
[or sysfs] is a common practice for debug purposes.

Also, our HW debug capabilities are highly-customable, and I want to
have the ability to configure those on the fly [E.g., dynamically
configuring various HW events to be recorded].
Each such configuration involves multiple register writes and reads
according to user provided inputs.
I don't really see how to generalize the information collection in a way
that would benefit anyone else.

> For your inhouse debugging, you should have oot
> patch to expose whatever you need.

I don't want in-house debugging capabilities -
I want field debug capabilities.
