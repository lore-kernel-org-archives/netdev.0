From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next V2] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Wed, 21 Sep 2016 12:10:55 +0200
Message-ID: <4617aca3-8d44-e99a-cc5a-1088b30ae327@stressinduktion.org>
References: <20160920185737.GU8920@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:51567 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753859AbcIUKK6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 06:10:58 -0400
In-Reply-To: <20160920185737.GU8920@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.09.2016 20:57, Sowmini Varadhan wrote:
> The vxlan header may not be aligned to 4 bytes in
> vxlan_build_skb (e.g., for MLD packets). This patch
> avoids unaligned access traps from vxlan_build_skb
> (in platforms like sparc) by making struct vxlanhdr __packed.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Performance wise this should only affect code generation for archs where
it matters anyway.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
