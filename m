From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: Commit "ipconfig wait for carrier" makes boot hang for 2 mins if no
 carrier
Date: Tue, 4 Sep 2012 20:04:59 +0200
Message-ID: <OF163B52E3.E2F5ACB3-ONC1257A6F.00635561-C1257A6F.00635564@transmode.se>
References: <504627A4.9080306@neli.hopto.org>,
	<OF61EF9E6E.9EF08C21-ONC1257A6F.004FE9B4-C1257A6F.0050A9B2@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Micha Nelissen <micha@neli.hopto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:60839 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757428Ab2IDSFC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 14:05:02 -0400
In-Reply-To: <504627A4.9080306@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Micha Nelissen <micha@neli.hopto.org> wrote: -----
> 
> Op 2012-09-04 16:41, Joakim Tjernlund schreef: > Above mentioned
> commit(3fb72f1e6e6165c5f495e8dc11c5bbd14c73385c) changes
> a ~1 sec delay to ~120 sec boot delay
> if no carrier. This is a really
> long time to wait if you just want to set an IP address but
> doesn't
> care about NFS root, holds up the boot with 2 minutes.
>
>  Why not set the IP address then in your rootfs yourself?  Micha 

I could ask you the same question, why do you need to have nfs in kernel?
The answer is probably the same, it is much easier to
manage our IP config in one place for our embedded system.

I don't understand why you need 2 minutes timeout for carrier either?

The wait should be conditional on NFS root or not so that non NFS roots
can skip this stage altogether.

 Jocke 