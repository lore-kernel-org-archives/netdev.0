From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC, PATCH 2.6.29.2] Ethernet V2.0 Configuration Testing Protocol, revision 20090428
Date: Mon, 04 May 2009 11:29:55 +0200
Message-ID: <87tz41gqr0.fsf@basil.nowhere.org>
References: <20090428220143.31395c24.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mark Smith
	<lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56951 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbZEDJ37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 05:29:59 -0400
In-Reply-To: <20090428220143.31395c24.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org> (Mark Smith's message of "Tue, 28 Apr 2009 22:01:43 +0930")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Smith <lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org> writes:
> +
> +4. Security
> +
> +ECTP was designed in the early 1980s, when protocol security was less of
> +a concern than it is now. Consequently, there are some features of the
> +protocol which could be abused for nefarious purposes. By default, this
> +implementation attempts to avoid participating in them. These features
> +could be useful for some test cases thought, so they can be enabled if
> +required.

I think security would need quite a bit more discussion. Opening new
DOS this way sounds quite worrying, especially since this is a
extremly obscure protocol that likely most admins don't know much
about.

Is this suspencible to ping to broadcast flood replication for example?

Safest would probably be default to off.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.
