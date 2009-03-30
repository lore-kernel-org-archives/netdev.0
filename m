From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Rework the TX logic.
Date: Mon, 30 Mar 2009 18:38:16 +0200
Message-ID: <OFEFCEAFB5.CC21FFBB-ONC1257589.005AEF16-C1257589.005B64EB@transmode.se>
References: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se>	<2a27d3730903270245k6e8633eehfb5cd3fcebd36240@mail.gmail.com> <OFDCE90357.0EDC5DC1-ONC1257586.003759A3-C1257586.00390AD3@transmode.se> <49CCD3E8.9040007@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Li Yang <leoli@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, pku.leo@gmail.com
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:53604 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686AbZC3QiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2009 12:38:20 -0400
In-Reply-To: <49CCD3E8.9040007@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood <scottwood@freescale.com> wrote on 27/03/2009 14:26:00:
> 
> Joakim Tjernlund wrote:
> > This is a bit better than the current type casts. Moving over to qe_bd
> > accesses is a bigger cleanup that will have to be a seperate patch.
> > I am not sure it is an all win as you probably loose the ability
> > to read both status and len in one access.
> 
> Not if you define the struct to have one status_len field (or a union of 

> that with separate fields), as gianfar does.

gianfar does not seem to use in_/out_ functions for the BDs. Works just
fine that too it seems. I always felt that the in_/out_ functions
was extra baggage that the Freescale CPUs don't need. There is
something in between that is missing.

 Jocke
