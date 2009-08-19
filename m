From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: mlx4 2.6.31-rc5: SW2HW_EQ failed.
Date: Wed, 19 Aug 2009 07:46:26 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908190743410.5621@gentwo.org>
References: <alpine.DEB.1.10.0908171523330.20399@gentwo.org> <ada7hx22j3g.fsf@cisco.com> <alpine.DEB.1.10.0908171814210.15956@gentwo.org> <ada3a7p3o6f.fsf@cisco.com> <adaljlg1e0x.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:35953 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751494AbZHSLqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 07:46:31 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D498682C864
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 07:46:47 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XYsOsAGDK6-v for <netdev@vger.kernel.org>;
	Wed, 19 Aug 2009 07:46:43 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 235DA82C624
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 07:46:43 -0400 (EDT)
In-Reply-To: <adaljlg1e0x.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Aug 2009, Roland Dreier wrote:

> By the way, my dual-socket nehalem EP system says:
>
>     SMP: Allowing 16 CPUs, 0 hotplug CPUs
>
> which I think (haven't checked but the code sure looks that way) means
> that num_possible_cpus() is 16.  This is a supermicro workstation board,
> forget the exact model.

Correct. My Dell R620 may have some weird ACPI info.

SMP: Allowing 32 CPUs, 16 hotplug CPUs

although the box does not have any slots for "hotplugging".


> And the fact that your system is different is not really a bug -- it
> just points to slightly incorrect data somewhere, most likely ACPI
> tables; having 32 possible CPUs on a system that can only ever really
> have 16 CPUs just leads to some overallocations, and tickles the mlx4
> bug where it can't handle more than 32 interrupts).

The patch does not fix the issue so far. We are having various hangs and
are trying to figure out what is gong on.

We ran an old 2.6.26 debian kernel on this and it worked fine.

