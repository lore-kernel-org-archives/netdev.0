From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: Increase frequency of load distribution over
 broadcast link
Date: Tue, 16 Mar 2010 21:27:11 -0700 (PDT)
Message-ID: <20100316.212711.66066041.davem@davemloft.net>
References: <20100315180223.GC24528@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36000
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752881Ab0CQE0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 00:26:49 -0400
In-Reply-To: <20100315180223.GC24528@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 15 Mar 2010 14:02:24 -0400

> Forward port commit 29eb572941501c40ac6e62dbc5043bf9ee76ee56
> from git://tipc.cslab.ericsson.net/pub/git/people/allan/tipc.git
> 
> Origional commit message:
> Increase frequency of load distribution over broadcast link
> 
> This patch enhances the behavior of TIPC's broadcast link so that it
> alternates between redundant bearers (if available) after every
> message sent, rather than after every 10 messages.  This change helps
> to speed up delivery of retransmitted messages by ensuring that
> they are not sent repeatedly over a bearer that is no longer working,
> but not yet recognized as failed.
> 
> Tested by myself in the latest net-2.6 tree using the tipc sanity test suite
> 
> Origionally-signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
