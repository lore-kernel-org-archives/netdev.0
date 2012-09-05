From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: Commit "ipconfig wait for carrier" makes boot hang for 2 mins if no
  carrier
Date: Wed, 5 Sep 2012 09:04:59 +0200
Message-ID: <OFFA3AC1B1.08FC3AAD-ONC1257A70.00266EDC-C1257A70.0026E8BC@transmode.se>
References: <504627A4.9080306@neli.hopto.org>,	<OF61EF9E6E.9EF08C21-ONC1257A6F.004FE9B4-C1257A6F.0050A9B2@transmode.se> <OF163B52E3.E2F5ACB3-ONC1257A6F.00635561-C1257A6F.00635564@transmode.se> <50465791.40805@neli.hopto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Micha Nelissen <micha@neli.hopto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:51197 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238Ab2IEHFD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 03:05:03 -0400
In-Reply-To: <50465791.40805@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha Nelissen <micha@neli.hopto.org> wrote on 2012/09/04 21:33:37:
>
> Joakim Tjernlund wrote:
> >>  Why not set the IP address then in your rootfs yourself?  Micha
> >
> > I could ask you the same question, why do you need to have nfs in kernel?
>
> Because that's where my root filesystem is? The IP autoconfiguration
> code exists for this purpose.

This is not the only purpose.

>
> > The answer is probably the same, it is much easier to
> > manage our IP config in one place for our embedded system.
>
> You retrieve the kernel via TFTP or so when booting?

Yes, but mostly not. This really doesn't matter

>
> > I don't understand why you need 2 minutes timeout for carrier either?
>
> Just a safe value.
>
> > The wait should be conditional on NFS root or not so that non NFS roots
> > can skip this stage altogether.
>
> Feel free to submit a patch :-)

Your patch broke other use cases so my patch would just revert or change the tmo
to 2 secs or so.
Or you could clean up your stuff so it works for all and not just for you.

 Jocke
