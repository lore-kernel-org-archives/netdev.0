From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.19rc2 XFRM does too large direct mapping allocations for
 hashes
Date: Wed, 18 Oct 2006 12:37:47 -0700 (PDT)
Message-ID: <20061018.123747.59655253.davem@davemloft.net>
References: <200610181350.22049.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53632
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161321AbWJRThj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 15:37:39 -0400
To: ak@suse.de
In-Reply-To: <200610181350.22049.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Wed, 18 Oct 2006 13:50:22 +0200

> I got this while restarting ipsec on a 2.6.19rc2 system that was
> up for a few days.

It's been fixed already in current GIT.

The xfrm state counters weren't being maintained correctly,
so they'd go "negative" and the hashing code thought it
needed a "huge" hash table. :-)
