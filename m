From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/2] macvtap: restore vlan header on user read
Date: Wed, 09 May 2012 21:24:54 -0400 (EDT)
Message-ID: <20120509.212454.2064064586130481812.davem@davemloft.net>
References: <1336121724-31902-2-git-send-email-basil.gor@gmail.com>
	<20120508192806.GB28536@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: basil.gor@gmail.com, ebiederm@xmission.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757981Ab2EJBZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 21:25:00 -0400
In-Reply-To: <20120508192806.GB28536@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 8 May 2012 22:28:06 +0300

> On Fri, May 04, 2012 at 12:55:24PM +0400, Basil Gor wrote:
>> Ethernet vlan header is not on the packet and kept in the skb->vlan_tci
>> when it comes from lower dev. This patch inserts vlan header in user
>> buffer during skb copy on user read.
>> 
>> Signed-off-by: Basil Gor <basil.gor@gmail.com>
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Eric, ack?

Eric please review these two patches.
