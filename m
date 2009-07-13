From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general][PATCH] mlx4_core: Synch catastrophic flow with module unload
Date: Mon, 13 Jul 2009 14:53:59 -0700
Message-ID: <adabpnouu4o.fsf@cisco.com>
References: <4A5B5274.2020801@mellanox.co.il>
	<20090713.111407.196601373.davem@davemloft.net>
	<adak52cv02r.fsf@cisco.com>
	<20090713.130936.41603615.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:29427 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756454AbZGMVyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 17:54:03 -0400
In-Reply-To: <20090713.130936.41603615.davem@davemloft.net> (David Miller's
	message of "Mon, 13 Jul 2009 13:09:36 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > If it gets sent to netdev, it's for a networking driver, and it says
 > "PATCH" rather than "RFC" or "please review" or "don't apply" you
 > cannot reasonably expect me to not look into applying the thing.

 > And if you're saying that patches for this device should start not
 > going through me, and the tactic to accomplish that is to move the
 > bulk of the driver into some driver/shared area, that's really weird.

Well, first of all, if a driver, networking or not, has an active
maintainer, I would expect you to give that maintainer a chance to look
at any not-totally-trivial patches affecting that driver.

But in this case, mlx4_core (as opposed to mlx4_en from the same
drivers/net/mlx4 directory) really is not a network driver -- it is a
low-level multiplexer for access to hardware that really is more
InfiniBand than ethernet (with a dash of Fibre Channel thrown in).  And
yes, I am saying that making it clearer that mlx4_core is not an
network driver by moving the source to a more appropriate place does
seem to make sense.

 > Anyways I didn't push the patch out to kernel.org yet so it's easy for
 > me to remove it.

Thanks.

 - R.
