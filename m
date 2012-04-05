From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Wed, 04 Apr 2012 20:21:09 -0400 (EDT)
Message-ID: <20120404.202109.2046106039992811660.davem@davemloft.net>
References: <20120403113751.21fd0b17@s6510.linuxnetplumber.net>
	<4F7CD4BC.4000006@enea.com>
	<20120404165559.5223ab95@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvid.brodin@enea.com, netdev@vger.kernel.org,
	balferreira@googlemail.com, arvid.brodin@xdin.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898Ab2DEAWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 20:22:07 -0400
In-Reply-To: <20120404165559.5223ab95@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 4 Apr 2012 16:55:59 -0700

> That isn't so bad, doing a memcpy versus a structure copy.

GCC is going to inline the memcpy and thus we'll still do the
unaligned accesses.  This change therefore won't fix the problem.
