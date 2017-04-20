From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [net-next 04/14] i40e: dump VF information in debugfs
Date: Thu, 20 Apr 2017 16:24:51 +0000
Message-ID: <BL2PR07MB23063D7F1341E629E9345F578D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <BL2PR07MB23064C036E994DC63475F7388D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
        <20170420113942.GD1886@nanopsycho.orion>
        <BL2PR07MB2306DEC60F085B88BA230C3A8D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170420.115153.1510206006505486594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
        "gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "mitch.a.williams@intel.com" <mitch.a.williams@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        "Dupuis, Chad" <Chad.Dupuis@cavium.com>,
        "Rangankar, Manish" <Manish.Rangankar@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0081.outbound.protection.outlook.com ([104.47.36.81]:29258
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S971155AbdDTQZA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 12:25:00 -0400
In-Reply-To: <20170420.115153.1510206006505486594.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I agree this surely isn't *our* convention, but for scsi  using
> > debugfs [or sysfs] is a common practice for debug purposes.
> >
> > Also, our HW debug capabilities are highly-customable, and I want to
> > have the ability to configure those on the fly [E.g., dynamically
> > configuring various HW events to be recorded].
> > Each such configuration involves multiple register writes and reads
> > according to user provided inputs.
> > I don't really see how to generalize the information collection in a
> > way that would benefit anyone else.
>=20
> That's basically what everyone says who slaps random crap into debugfs.=20

True; But assuming that means the suggestion to use debugfs means the
content is random crap is a logical fallacy.

> >> For your inhouse debugging, you should have oot patch to expose
> >> whatever you need.
> >
> > I don't want in-house debugging capabilities - I want field debug
> > capabilities.
>=20
> Then it has to use a portable, well defined, set of interfaces.

How would you be able to describe something that is completely tied
to a specific HW this way. E.g., let's assume you'd want to record
some messages that pass between 2 internal processors that match
some criteria?
While you can probably standardize some format from such a matching
[although that too would be very tied to different HW capabilities],
the HW pipeline itself can't be abstracted in this case.
