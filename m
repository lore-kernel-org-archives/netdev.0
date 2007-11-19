From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: [PATCH 0/5] fixups for mpc8360 rev. 2.1 erratum #2 (RGMII
 Timing)
Date: Mon, 19 Nov 2007 17:36:52 -0600
Message-ID: <20071119173652.55e385b2.kim.phillips@freescale.com>
References: <20071105121530.5c38fbb7.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, paulus@samba.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:53730 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbXKSXhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 18:37:51 -0500
In-Reply-To: <20071105121530.5c38fbb7.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Nov 2007 12:15:30 -0600
Kim Phillips <kim.phillips@freescale.com> wrote:

> Hello all,
> 
> the following patches fix RGMII timing for rev. 2.1 of the mpc8360,
> according to erratum #2 (erratum text included below).  Basically the
> most intrusive part is the addition of two new RGMII Internal Delay
> modes; one for TX delay only, and the other for RX delay only (i.e, not
> both at the same time).
> 
> Please review, and since this affects both netdev and powerpc trees,
> one maintainer should ack them for the other to push upstream (i.e,
> Kumar acks them, and Leo picks them up to go through netdev or the
> other way around; either way is fine with me).  I'm hoping they're
> trivial enough to go in 2.6.24.
> 
Kumar, Leo, 

re-ping due to (a) it's been 2 weeks and (b) Anton Vorontsov has since
issued his Tested-by.

Might I suggest Kumar ack the powerpc patches, and Leo/Jeff apply 5/5
to go through netdev?

Kim
