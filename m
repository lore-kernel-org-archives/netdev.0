From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: Allow retransmission of cloned buffers
Date: Tue, 16 Mar 2010 21:27:06 -0700 (PDT)
Message-ID: <20100316.212706.95906313.davem@davemloft.net>
References: <20100315175845.GB24528@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35995
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752832Ab0CQE0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 00:26:44 -0400
In-Reply-To: <20100315175845.GB24528@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 15 Mar 2010 13:58:45 -0400

> Forward port commit
> fc477e160af086f6e30c3d4fdf5f5c000d29beb5
> from git://tipc.cslab.ericsson.net/pub/git/people/allan/tipc.git
> 
> Origional commit message:
> 
> Allow retransmission of cloned buffers
> 
> This patch fixes an issue with TIPC's message retransmission logic
> that prevented retransmission of clone sk_buffs.  Originally intended
> as a means of avoiding wasted work in retransmitting messages that
> were still on the driver's outbound queue, it also prevented TIPC
> from retransmitting messages through other means -- such as the
> secondary bearer of the broadcast link, or another interface in a
> set of bonded interfaces.  This fix removes existing checks for
> cloned sk_buffs that prevented such retransmission.
> 
> Origionally-Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
