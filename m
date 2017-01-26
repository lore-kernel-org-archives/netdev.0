From: KY Srinivasan <kys@microsoft.com>
Subject: RE: netvsc NAPI patch process
Date: Thu, 26 Jan 2017 20:46:40 +0000
Message-ID: <DM5PR03MB249073BDE0362C6A7051AA8EA0770@DM5PR03MB2490.namprd03.prod.outlook.com>
References: <20170126100405.0eac2dea@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0103.outbound.protection.outlook.com ([104.47.37.103]:54041
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752822AbdAZUrX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 15:47:23 -0500
In-Reply-To: <20170126100405.0eac2dea@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Thursday, January 26, 2017 10:04 AM
> To: davem@davemloft.net; KY Srinivasan <kys@microsoft.com>; Greg KH
> <greg@kroah.com>
> Cc: netdev@vger.kernel.org
> Subject: netvsc NAPI patch process
>=20
> I have a working set of patches to enable NAPI in the netvsc driver.
> The problem is that it requires a set of patches to vmbus layer as well.
> Since vmbus patches have been going through char-misc-next tree rather
> than net-next, it is difficult to stage these.

In the past, we have done this in two stages - get the supporting vmbus pat=
ches into
Greg's tree first and in the next merge cycle get the netvsc patches in. Wh=
y not continue to
do what we have done in the past to address cross-tree dependencies.

Regards,

K. Y=20
>=20
> How about if I send the vmbus patches through normal driver-devel
> upstream
> and during the 4.10 merge window send the last 3 patches for NAPI for lin=
ux-
> net
> tree to get into 4.10?
