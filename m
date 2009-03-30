From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Rework the TX logic.
Date: Mon, 30 Mar 2009 19:34:53 +0200
Message-ID: <OF3127420C.081D4097-ONC1257589.00603E3D-C1257589.006093B3@transmode.se>
References: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se>	<2a27d3730903270245k6e8633eehfb5cd3fcebd36240@mail.gmail.com> <OFDCE90357.0EDC5DC1-ONC1257586.003759A3-C1257586.00390AD3@transmode.se> <49CCD3E8.9040007@freescale.com> <OFEFCEAFB5.CC21FFBB-ONC1257589.005AEF16-C1257589.005B64EB@transmode.se> <49D0FFBB.7000009@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Li Yang <leoli@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, pku.leo@gmail.com
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:49490 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751755AbZC3Rez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2009 13:34:55 -0400
In-Reply-To: <49D0FFBB.7000009@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood <scottwood@freescale.com> wrote on 30/03/2009 19:22:03:
> 
> Joakim Tjernlund wrote:
> > gianfar does not seem to use in_/out_ functions for the BDs. Works 
just
> > fine that too it seems.
> 
> It does now that it has explicit barriers in a few places.  Before they

In 2.6.29 or later?
 
> were added, it would sometimes fail under load.  That was due to a 
> compiler reordering, but CPU reordering was possible as well.

Does not the CPU skip reordering if the guarded bit is set?

Could we not use the same in ucc_geth as well? Then people would
not need to worry about "performance issues".

 Jocke
