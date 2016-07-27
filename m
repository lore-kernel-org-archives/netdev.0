From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] qed: Add and use specific logging functions to reduce
 object size
Date: Wed, 27 Jul 2016 07:32:18 +0000
Message-ID: <CO2PR11MB0088AF8C3194FE63E5200054970F0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <a0e0111217e9df2ae8dfd681b2810230e00f634e.1469568146.git.joe@perches.com>
 <1469582642.4159.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Dept-Eng Everest Linux L2 <Dept-EngEverestLinuxL2@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0106.outbound.protection.outlook.com ([104.47.37.106]:33443
	"EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751339AbcG0Hq7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 03:46:59 -0400
In-Reply-To: <1469582642.4159.4.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Current DP_ macros generate a lot of code.
> > Using functions with vsprintf extension %pV helps reduce that size.
>=20
> Yuval, I used the same KERN_<LEVEL> output types, but it is unusual
> that=A0DP_INFO outputs at KERN_NOTICE.
>=20
> Was that a copy/paste defect or should it be emitted at KERN_INFO and
> DP_VERBOSE be emitted at KERN_DEBUG?

I agree it's a bit odd, but it's actually by design -=20
as none of these prints would ever be reached unless user explicitly en=
able
them [ethtool/module param], the assumption is that NOTICE is good
enough, i.e., it will prevent the need for doing additional configurati=
on of
logging levels by the user.
