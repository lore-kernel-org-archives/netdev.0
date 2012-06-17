From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: mlx4_core: Modify driver initialization flow to accommodate SRIOV for Ethernet
Date: Sun, 17 Jun 2012 18:18:05 +0300
Message-ID: <201206171818.05299.jackm@dev.mellanox.co.il>
References: <20120609090918.GB877@elgon.mountain> <201206091429.17171.jackm@dev.mellanox.co.il> <1339290217.21665.164.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Carpenter <dan.carpenter@oracle.com>, netdev@vger.kernel.org,
	dotanb@mellanox.co.il, Or Gerlitz <ogerlitz@mellanox.com>,
	yevgenyp@mellanox.co.il
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:44302 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757486Ab2FQPP7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 11:15:59 -0400
Received: by wibhn6 with SMTP id hn6so1194978wib.1
        for <netdev@vger.kernel.org>; Sun, 17 Jun 2012 08:15:57 -0700 (PDT)
In-Reply-To: <1339290217.21665.164.camel@deadeye.wl.decadent.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 10 June 2012 04:03, Ben Hutchings wrote:
> It would be more idiomatic to write the condition as:
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (hca_param.global_=
caps & ~(u64)HCA_GLOBAL_CAP_MASK)
>=20
> (although that cast probably belongs in the definition of
> HCA_GLOBAL_CAP_MASK).
>=20
You are correct!
We need to submit a patch to fix this.

-Jack
