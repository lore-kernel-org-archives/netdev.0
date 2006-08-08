From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 08 Aug 2006 02:12:24 -0700 (PDT)
Message-ID: <20060808.021224.54189909.davem@davemloft.net>
References: <20060807164842.GA3412@ms2.inr.ac.ru>
	<20060807.204214.68039839.davem@davemloft.net>
	<200608081057.32022.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29870
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932548AbWHHJMV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 05:12:21 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200608081057.32022.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 8 Aug 2006 10:57:31 +0200

> I think we had discussion about being able to dynamically resize
> route hash table (or tcp hash table), using RCU. Did someone worked
> on this ?  For most current machines (ram size >= 1GB) , the default
> hash table sizes are just insane for 99% of uses.

Specifically we were talking about TCP recently, but yes the
same rings true for the routing cache as well.
