From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v7 net-next 01/16] gso: Remove arbitrary checks for
 unsupported GSO
Date: Sat, 21 May 2016 03:02:30 +0200
Message-ID: <cc2e026a-6ab0-8d52-5c3d-29843c6ddf40@stressinduktion.org>
References: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
 <1463587584-2315623-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, "Michael S. Tsirkin" <mst@redhat.com>
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:44131 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751591AbcEUBCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 21:02:34 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id D95A020969
	for <netdev@vger.kernel.org>; Fri, 20 May 2016 21:02:33 -0400 (EDT)
In-Reply-To: <1463587584-2315623-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 18.05.2016 18:06, Tom Herbert wrote:
> In several gso_segment functions there are checks of gso_type against
> a seemingly arbitrary list of SKB_GSO_* flags. This seems like an
> attempt to identify unsupported GSO types, but since the stack is
> the one that set these GSO types in the first place this seems
> unnecessary to do. If a combination isn't valid in the first
> place that stack should not allow setting it.
> 
> This is a code simplication especially for add new GSO types.

I couldn't still wrap my head around this.

I wonder if this is safe in case of if the packet is generated from an
untrusted virtual machine over virtio_net?

Bye,
Hannes
