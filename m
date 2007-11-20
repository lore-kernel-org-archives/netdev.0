From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH, take2] netfilter : struct xt_table_info diet
Date: Tue, 20 Nov 2007 08:54:56 +0100
Message-ID: <474292D0.7000603@trash.net>
References: <473B6D88.4010701@cosmosbay.com> <20071120063225.GA18035@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56519 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756627AbXKTHzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 02:55:03 -0500
In-Reply-To: <20071120063225.GA18035@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Horman wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
>
> Instead of using a big array of NR_CPUS entries, we can compute the size
> needed at runtime, using nr_cpu_ids
>
> This should save some ram (especially on David's machines where NR_CPUS=4096 :
> 32 KB can be saved per table, and 64KB for dynamically allocated ones (because
> of slab/slub alignements) )
>
> In particular, the 'bootstrap' tables are not any more static (in data
> section) but on stack as their size is now very small.
>
> This also should reduce the size used on stack in compat functions
> (get_info() declares an automatic variable, that could be bigger than kernel
> stack size for big NR_CPUS)

This seems to be identical to the patch I already got queued
apart from reintroducing the NR_CPUS check. Am I missing
something?

