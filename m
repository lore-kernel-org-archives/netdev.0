From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Fix logic breakage due to DSACK separation
Date: Fri, 15 Jun 2007 15:14:39 -0700 (PDT)
Message-ID: <20070615.151439.70217492.davem@davemloft.net>
References: <Pine.LNX.4.64.0706151606220.15358@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34103
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755580AbXFOWOU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2007 18:14:20 -0400
In-Reply-To: <Pine.LNX.4.64.0706151606220.15358@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 15 Jun 2007 16:07:37 +0300 (EEST)

> Commit 6f74651ae626ec672028587bc700538076dfbefb is found guilty
> of breaking DSACK counting, which should be done only for the
> SACK block reported by the DSACK instead of every SACK block
> that is received along with DSACK information.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Thanks for performing such rigorous audits and finding
regressions like this!

Patch applied.
