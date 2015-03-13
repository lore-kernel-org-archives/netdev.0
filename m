From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next ] mpls: In mpls_egress verify the packet
 length.
Date: Thu, 12 Mar 2015 23:05:18 -0400 (EDT)
Message-ID: <20150312.230518.609381926355395030.davem@davemloft.net>
References: <20150312.182558.447886504045770209.davem@davemloft.net>
	<87h9tpzv76.fsf@x220.int.ebiederm.org>
	<87a8zhztpo.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rshearma@brocade.com, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbbCMDFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 23:05:20 -0400
In-Reply-To: <87a8zhztpo.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 12 Mar 2015 18:22:59 -0500

> 
> Reobert Shearman noticed that mpls_egress is failing to verify that
> the bytes to be examined are in fact present in the packet before
> mpls_egress reads those bytes.
> 
> As suggested by David Miller reduce this to a single pskb_may_pull
> call so that we don't do unnecessary work in the fast path.
> 
> Reported-by: Robert Shearman <rshearma@brocade.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Perfect, applied, thanks!
