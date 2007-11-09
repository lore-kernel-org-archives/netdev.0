From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 0/5] fixups for mpc8360 rev. 2.1 erratum #2 (RGMII Timing)
Date: Fri, 9 Nov 2007 16:33:50 +0300
Message-ID: <20071109133350.GB21232@localhost.localdomain>
References: <20071105121530.5c38fbb7.kim.phillips@freescale.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, paulus@samba.org, jgarzik@pobox.com
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:56162 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759178AbXKINgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 08:36:21 -0500
Content-Disposition: inline
In-Reply-To: <20071105121530.5c38fbb7.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 05, 2007 at 12:15:30PM -0600, Kim Phillips wrote:
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

All five patches are

Tested-by: Anton Vorontsov <avorontsov@ru.mvista.com>


Let's hope they'll hit 2.6.24.

Thanks,

-- 
Anton Vorontsov
email: cbou@mail.ru
backup email: ya-cbou@yandex.ru
irc://irc.freenode.net/bd2
