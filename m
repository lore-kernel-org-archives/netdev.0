From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-2.6.28] net: jme.c rxdesc.flags is __le16, other
 missing endian swaps
Date: Wed, 19 Nov 2008 15:51:10 -0800 (PST)
Message-ID: <20081119.155110.213037648.davem@davemloft.net>
References: <1226957405.6150.8.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42013
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751931AbYKSXvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 18:51:10 -0500
In-Reply-To: <1226957405.6150.8.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Mon, 17 Nov 2008 13:30:05 -0800

> This is the minimal patch to fix endian mismatches.  These are
> probably bugs on big-endian arches, noops on little endian.
> 
> jme_rxsum_ok could be improved to directly take a __le16 and
> change all of the masks/sets to be in little-endian, but
> has not been done here to keep the patch small.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
> Dave, could use confirmation here, but looks almost certainly like a bugfix
> for big-endian.

This looks good, applied, thanks Harvey.
