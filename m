From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] correct IGMP behavior on v3 query during
 v2-compatibility mode
Date: Sun, 03 Oct 2010 22:01:05 -0700 (PDT)
Message-ID: <20101003.220105.115939978.davem@davemloft.net>
References: <1285892980.21804.7.camel@w-dls.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44026
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751771Ab0JDFAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 01:00:44 -0400
In-Reply-To: <1285892980.21804.7.camel@w-dls.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <dlstevens@us.ibm.com>
Date: Thu, 30 Sep 2010 17:29:40 -0700

> A recent patch to allow IGMPv2 responses to IGMPv3 queries
> bypasses length checks for valid query lengths, incorrectly
> resets the v2_seen timer, and does not support IGMPv1.
> 
> The following patch responds with a v2 report as required
> by IGMPv2 while correcting the other problems introduced
> by the patch.
> 
> Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

Applied, thanks David.
