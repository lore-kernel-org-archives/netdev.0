From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] igmp: Avoid zero delay when receiving odd mixture
 of IGMP queries
Date: Mon, 09 Jan 2012 14:07:10 -0800 (PST)
Message-ID: <20120109.140710.878631265211408713.davem@davemloft.net>
References: <20120109220428.GS20752@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, smcv@debian.org, 654876@bugs.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932566Ab2AIWHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 17:07:22 -0500
In-Reply-To: <20120109220428.GS20752@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 9 Jan 2012 22:04:28 +0000

> Commit 5b7c84066733c5dfb0e4016d939757b38de189e4 ('ipv4: correct IGMP
> behavior on v3 query during v2-compatibility mode') added yet another
> case for query parsing, which can result in max_delay = 0.  Substitute
> a value of 1, as in the usual v3 case.
> 
> Reported-by: Simon McVittie <smcv@debian.org>
> References: http://bugs.debian.org/654876
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied and queued up for -stable, thanks Ben.
