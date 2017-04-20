From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [net-next 04/14] i40e: dump VF information in debugfs
Date: Thu, 20 Apr 2017 20:50:55 +0000
Message-ID: <BL2PR07MB230655E4217E619BABCA54D18D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <BL2PR07MB23063D7F1341E629E9345F578D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
        <20170420.125841.799913763607507081.davem@davemloft.net>
        <BL2PR07MB23064B547F325DD002E513FC8D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170420.163548.662307112452546016.davem@davemloft.net>
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
Received: from mail-bn3nam01on0045.outbound.protection.outlook.com ([104.47.33.45]:38373
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1032143AbdDTUvB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 16:51:01 -0400
In-Reply-To: <20170420.163548.662307112452546016.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I surely wouldn't want to write a million lines of code just to
> > provide such a detailed abstraction.
>=20
> So now the argument has gone from "it's not possible" to "it's going to b=
e a
> HUGE amount of code."

Nothing here's is strictly impossible - you can always create a simulated H=
W
model in SW, and have a one-to-one mapping with the HW entities.
But "unreasonable amount of code" comes very close to it.

> I wonder what the next argument will be when I shoot this one down.
>=20
> If you simply don't want to do the hard work necessary to implement this
> properly, which is fine, just say so.

Nope, I don't mind doing the work. What I would appreciate is some
constructive suggestions on a seemingly feasible approach that might work.
I feel like I've been bashed enough for one day. :-)
