From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next V2] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Wed, 21 Sep 2016 11:43:13 +0200
Message-ID: <20160921114313.07a43f14@griffin>
References: <20160920185737.GU8920@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hannes@stressinduktion.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35710 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933169AbcIUJnR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 05:43:17 -0400
In-Reply-To: <20160920185737.GU8920@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 14:57:37 -0400, Sowmini Varadhan wrote:
> The vxlan header may not be aligned to 4 bytes in
> vxlan_build_skb (e.g., for MLD packets). This patch
> avoids unaligned access traps from vxlan_build_skb
> (in platforms like sparc) by making struct vxlanhdr __packed.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Acked-by: Jiri Benc <jbenc@redhat.com>
