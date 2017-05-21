From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] arp: always override existing neigh entries
 with gratuitous ARP
Date: Sun, 21 May 2017 13:27:14 -0400 (EDT)
Message-ID: <20170521.132714.234436043096021169.davem@davemloft.net>
References: <cover.1495136258.git.ihrachys@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: ihrachys@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45006 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdEUR1Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:27:16 -0400
In-Reply-To: <cover.1495136258.git.ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ihar Hrachyshka <ihrachys@redhat.com>
Date: Thu, 18 May 2017 12:41:17 -0700

> This patchset is spurred by discussion started at
> https://patchwork.ozlabs.org/patch/760372/ where we figured that there is no
> real reason for enforcing override by gratuitous ARP packets only when
> arp_accept is 1. Same should happen when it's 0 (the default value).
> 
> changelog v2: handled review comments by Julian Anastasov
> - fixed a mistake in a comment;
> - postponed addr_type calculation to as late as possible.

Series applied, thanks.

Please address the feedback from Julian about the ieee1394 change
you put into ARP earlier.

Thanks.
