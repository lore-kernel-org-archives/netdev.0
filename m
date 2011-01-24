From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Mon, 24 Jan 2011 17:34:04 +0100
Message-ID: <1295886844.2755.36.camel@edumazet-laptop>
References: <D3F292ADF945FB49B35E96C94C2061B90ECC4FAC@nsmail.netscout.com>
	 <13dbf221c875a931d408784495884998.squirrel@www.liukuma.net>
	 <alpine.WNT.2.00.1101211400000.5816@JBRANDEB-DESK2.amr.corp.intel.com>
	 <8ad1defdf427ceb7af94fad4d216b006.squirrel@www.liukuma.net>
	 <30747065682effddc661b8cd235553d9.squirrel@www.liukuma.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Loke, Chetan" <chetan.loke@netscout.com>,
	Jon Zhou <jon.zhou@jdsu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: juice@swagman.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41308 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416Ab1AXQgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 11:36:15 -0500
Received: by bwz15 with SMTP id 15so3730912bwz.19
        for <netdev@vger.kernel.org>; Mon, 24 Jan 2011 08:36:14 -0800 (PST)
In-Reply-To: <30747065682effddc661b8cd235553d9.squirrel@www.liukuma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 24 janvier 2011 =C3=A0 10:10 +0200, juice a =C3=A9crit :

> Result: OK: 12345544(c12344739+d804) nsec, 10000000 (60byte,0frags)
>   810008pps 388Mb/sec (388803840bps) errors: 0
>=20

>=20
> This is a bit better than the previous maxim of 750064pps / 360Mb/sec
> that I was able to achieve without tuning parameters with ethtool, bu=
t
> still not near the 1.1Mpacks/s that shoud be doable with my card?

Please check what numbers you can get using dummy0 device instead of
real ethernet driver.

Here : (E5540  @ 2.53GHz) clone =3D 1

Result: OK: 34775941(c34775225+d716) nsec, 100000000 (60byte,0frags)
  2875551pps 1380Mb/sec (1380264480bps) errors: 0



