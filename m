From: Roland Dreier <rdreier@cisco.com>
Subject: Re: mlx4 2.6.31-rc5: SW2HW_EQ failed.
Date: Wed, 19 Aug 2009 00:03:26 -0700
Message-ID: <adaljlg1e0x.fsf@cisco.com>
References: <alpine.DEB.1.10.0908171523330.20399@gentwo.org>
	<ada7hx22j3g.fsf@cisco.com>
	<alpine.DEB.1.10.0908171814210.15956@gentwo.org>
	<ada3a7p3o6f.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:39516 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbZHSHDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 03:03:25 -0400
In-Reply-To: <ada3a7p3o6f.fsf@cisco.com> (Roland Dreier's message of "Mon, 17
	Aug 2009 18:28:56 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By the way, my dual-socket nehalem EP system says:

    SMP: Allowing 16 CPUs, 0 hotplug CPUs

which I think (haven't checked but the code sure looks that way) means
that num_possible_cpus() is 16.  This is a supermicro workstation board,
forget the exact model.

And the fact that your system is different is not really a bug -- it
just points to slightly incorrect data somewhere, most likely ACPI
tables; having 32 possible CPUs on a system that can only ever really
have 16 CPUs just leads to some overallocations, and tickles the mlx4
bug where it can't handle more than 32 interrupts).

Just FWIW.

 - R.
