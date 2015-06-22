From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 03/12] netfilter: x_tables: align per cpu xt_counter
Date: Mon, 22 Jun 2015 11:49:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB54634@AcuExch.aculab.com>
References: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
 <1434734269-4545-4-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.187]:51880 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754750AbbFVLvX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 07:51:23 -0400
In-Reply-To: <1434734269-4545-4-git-send-email-pablo@netfilter.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso
> Sent: 19 June 2015 18:18
> From: Eric Dumazet <edumazet@google.com>
> 
> Let's force a 16 bytes alignment on xt_counter percpu allocations,
> so that bytes and packets sit in same cache line.
> 
> xt_counter being exported to user space, we cannot add __align(16) on
> the structure itself.

You could allocate a wrapper structure that contains xt_counter
and is itself marked __align(16).

	David
