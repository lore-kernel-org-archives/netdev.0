From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] packet: Add pre-defragmentation support for ipv4
 fanouts.
Date: Tue, 05 Jul 2011 03:06:39 -0700 (PDT)
Message-ID: <20110705.030639.1088590555237733790.davem@davemloft.net>
References: <20110705.020426.1881513648974221645.davem@davemloft.net>
	<4E12DAED.3070408@inliniac.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: victor@inliniac.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395Ab1GEKG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 06:06:57 -0400
In-Reply-To: <4E12DAED.3070408@inliniac.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Victor Julien <victor@inliniac.net>
Date: Tue, 05 Jul 2011 11:35:41 +0200

> On 07/05/2011 11:04 AM, David Miller wrote:
>> 
>> The skb->rxhash cannot be properly computed if the
>> packet is a fragment.  To alleviate this, allow the
>> AF_PACKET client to ask for defragmentation to be
>> done at demux time.
> 
> Does the same limitation exist for IPv6 packets?

Yes.

> If I read the patch correctly the defrag is only done for IPv4.

Right, one thing at a time :-)
