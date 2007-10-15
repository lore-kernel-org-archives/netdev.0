From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] Move common fields from frag_queues in one place
Date: Mon, 15 Oct 2007 02:24:43 -0700 (PDT)
Message-ID: <20071015.022443.51859270.davem@davemloft.net>
References: <470F6EAE.60308@openvz.org>
	<470F6FD6.20004@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52689
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757399AbXJOJYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:24:39 -0400
In-Reply-To: <470F6FD6.20004@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 12 Oct 2007 17:00:06 +0400

> Introduce the struct inet_frag_queue in include/net/inet_frag.h
> file and place there all the common fields from three structs:
> 
>  * struct ipq in ipv4/ip_fragment.c
>  * struct nf_ct_frag6_queue in nf_conntrack_reasm.c
>  * struct frag_queue in ipv6/reassembly.c
> 
> After this, replace these fields on appropriate structures with
> this structure instance and fix the users to use correct names
> i.e. hunks like
> 
> -    atomic_dec(&fq->refcnt);
> +    atomic_dec(&fq->q.refcnt);
> 
> (these occupy most of the patch)
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
