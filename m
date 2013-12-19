From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] nf-nat: don't use per destination incrementing ports
 in nat random mode
Date: Fri, 20 Dec 2013 00:21:15 +0100
Message-ID: <52B37F6B.9010105@redhat.com>
References: <20131219134007.GA24118@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46102 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755309Ab3LSXVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 18:21:24 -0500
In-Reply-To: <20131219134007.GA24118@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2013 02:40 PM, Hannes Frederic Sowa wrote:
> Don't use per destination incrementing port allocation
> in NF_NAT_RANGE_PROTO_RANDOM mode as advised in
> <https://sites.google.com/site/hayashulman/files/NIC-derandomisation.pdf>.
>
> This is especially important for UDP/DNS.
>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

I would have liked a more elaborate commit message ;) but anyway,
lgtm, now that we also have periodic reseeding in prandom:

Reviewed-by: Daniel Borkmann <dborkman@redhat.com>

The referenced paper in section 5 is also available here:

http://arxiv.org/pdf/1205.5190v1.pdf
