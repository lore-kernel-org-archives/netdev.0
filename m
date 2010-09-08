From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCHv4] net: Add batman-adv meshing protocol
Date: Wed, 08 Sep 2010 09:14:29 +0200
Message-ID: <87sk1kiu5m.fsf@basil.nowhere.org>
References: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.net
To: Sven Eckelmann <sven.eckelmann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49789 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957Ab0IHHOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 03:14:34 -0400
In-Reply-To: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de> (Sven
	Eckelmann's message of "Sun, 5 Sep 2010 02:25:53 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sven Eckelmann <sven.eckelmann@gmx.de> writes:

> B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is a routing
> protocol for multi-hop ad-hoc mesh networks. The networks may be wired or
> wireless. See http://www.open-mesh.org/ for more information and user space
> tools.

It seems rather unusual to have the complete routing protocol in
kernel. And this is a lot of code. The normal way to do such things is
to have the routing policy etc. in a user daemon and only let the kernel
provide some services to this. 

Could you elaborate a bit why this approach was not chosen?

I assume if it needs a switch it could have a switching "hot path" layer
in kernel and the policy somewhere else.

You write

> +Batman advanced was implemented as a Linux kernel driver  to  re-
> +duce the overhead to a minimum. It does not depend on any (other)

What overhead exactly?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
