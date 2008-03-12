From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove NPROTO.
Date: Tue, 11 Mar 2008 21:14:41 -0700 (PDT)
Message-ID: <20080311.211441.105701252.davem@davemloft.net>
References: <200803121224.25228.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56410
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751213AbYCLEOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 00:14:35 -0400
In-Reply-To: <200803121224.25228.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 12 Mar 2008 12:24:25 +1100

> NPROTO seems redundant; it's equal to AF_MAX/PF_MAX.
> 
> It's fairly simple to find all users and replace them appropriately.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Redundant, but exported to userspace for about 15 years.

We'd be wise to not remove it.
