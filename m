From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 08 Aug 2006 17:11:52 -0700 (PDT)
Message-ID: <20060808.171152.58440635.davem@davemloft.net>
References: <200608080711.06788.ak@suse.de>
	<Pine.LNX.4.61.0608081316330.2452@localhost.localdomain>
	<200608090123.01123.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, kuznet@ms2.inr.ac.ru, dev@sw.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31185
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030365AbWHIALs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 20:11:48 -0400
To: ak@suse.de
In-Reply-To: <200608090123.01123.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Wed, 9 Aug 2006 01:23:01 +0200

> The problem is to find out what a good boundary is.

The more I think about this the more I lean towards
two conclusions:

1) dynamic table growth is the only reasonable way to
   handle this and not waste memory in all cases

2) for cases where we haven't implemented dynamic
   table growth, specifying a proper limit argument
   to the hash table allocation is a sufficient
   solution for the time being
