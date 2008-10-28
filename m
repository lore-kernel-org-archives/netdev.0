From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: don't use INIT_RCU_HEAD
Date: Tue, 28 Oct 2008 16:29:06 +0100
Message-ID: <49072FC2.8030801@trash.net>
References: <20081028133124.GA3006@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34095 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbYJ1P3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 11:29:09 -0400
In-Reply-To: <20081028133124.GA3006@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> call_rcu() will unconditionally rewrite RCU head anyway.
> Applies to 
> 	struct neigh_parms
> 	struct neigh_table
> 	struct net
> 	struct cipso_v4_doi
> 	struct in_ifaddr
> 	struct in_device
> 	rt->u.dst

It would probably make sense to get a statement from Paul
whether this might be required in the future, f.i. for some
debugging feature.
