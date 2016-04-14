From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC 1/2] tun: don't require serialization lock on tx
Date: Thu, 14 Apr 2016 12:27:25 +0200
Message-ID: <570F708D.6060401@stressinduktion.org>
References: <cover.1460393493.git.pabeni@redhat.com>
 <425e8f69ffd8fe315ef9d3cc678519c7060fb2e0.1460393493.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:35877 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754440AbcDNK12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 06:27:28 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 2C7E620173
	for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 06:27:27 -0400 (EDT)
In-Reply-To: <425e8f69ffd8fe315ef9d3cc678519c7060fb2e0.1460393493.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13.04.2016 11:04, Paolo Abeni wrote:
> The current tun_net_xmit() implementation don't need any external
> lock since it relay on rcu protection for the tun data structure
> and on socket queue lock for skb queuing.
>
> This patch set the NETIF_F_LLTX feature bit in the tun device, so
> that on xmit, in absence of qdisc, no serialization lock is acquired
> by the caller.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
