From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Wed, 2 Dec 2009 08:59:25 +0100
Message-ID: <20091202085925.472136e2@houba>
References: <20091127223545.2a752429@houba>
 <alpine.DEB.2.00.0911272358030.11977@melkinpaasi.cs.helsinki.fi>
 <20091128010156.1219012a@houba>
 <alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi>
 <20091130195004.38dbc319@houba>
 <alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi>
 <20091130213727.2f4047d2@houba>
 <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
 <20091201211945.505d3c98@houba>
 <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:59318 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbZLBH7p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 02:59:45 -0500
In-Reply-To: <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Tue, 1 Dec 2009 22:27:01 +0200 (EET),
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :

> On Tue, 1 Dec 2009, Frederic Leroy wrote:
>
> Thanks, I'll hopefully have some time tomorrow to go through all the
> new ones. In the meantime, can you provide your tso configuration on
> houba (ethtool -k dev).

No tso on the interface :=20

houba ~ # ethtool -k wlan1
Offload parameters for wlan1:
Cannot get device rx csum settings: Operation not supported
Cannot get device tx csum settings: Operation not supported
Cannot get device scatter-gather settings: Operation not supported
Cannot get device tcp segmentation offload settings: Operation not
supported Cannot get device udp large send offload settings: Operation
not supported Cannot get device generic segmentation offload settings:
Operation not supported no offload info available

> Also,
> I wonder if you have had some working (past) kernel version?

I tried a 2.6.31, and it seems to work. If it really work (connection
don't stall everytime at the moment), I'll try to make a "git bisect"
asap.

> No need for additional traces atm, I'll get back to this once I've
> gone through the logs.

Ok :)

--=20
=46r=C3=A9d=C3=A9ric Leroy
