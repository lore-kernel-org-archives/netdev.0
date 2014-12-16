From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP
 Statistics (Web10G)
Date: Tue, 16 Dec 2014 15:03:54 -0500 (EST)
Message-ID: <20141216.150354.64901094367530710.davem@davemloft.net>
References: <CAADnVQ+rmBMoDRRu-Dtp7QBMJEbto9nb2zvFEXBCQsqpg6tS9A@mail.gmail.com>
	<20141216.140919.44020047339373813.davem@davemloft.net>
	<54908FAD.5060500@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: rapier@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbaLPUEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 15:04:00 -0500
In-Reply-To: <54908FAD.5060500@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: rapier <rapier@psc.edu>
Date: Tue, 16 Dec 2014 15:01:49 -0500

> On 12/16/14, 2:09 PM, David Miller wrote:
>> It's a non-starter.
> 
> Understood. We're in the process of reviewing which symbols are
> required by the DLKM we've provided and which are required by in tree
> modules (e.g tcp_estats_enabled is required by tcp_htcp).

You shouldn't need to export any symbols.
