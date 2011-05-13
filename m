From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/2 (V2)] stmmac: don't go through ethtool to start
 auto-negotiation
Date: Fri, 13 May 2011 16:12:19 -0400 (EDT)
Message-ID: <20110513.161219.2212949243676219098.davem@davemloft.net>
References: <1305268085-603-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, decot@google.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178Ab1EMUM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 16:12:26 -0400
In-Reply-To: <1305268085-603-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri, 13 May 2011 08:28:04 +0200

> From: David Decotigny <decot@google.com>
> 
> The driver used to call phy's ethtool configuration routine to start
> auto-negotiation. This change has it call directly phy's routine to
> start auto-negotiation.
> 
> The initial version was hiding phy_start_aneg() return value,
> this patch returns it (<0 upon error).
> 
> Tested: module compiles, tested on STM HDK7108 STB.
> 
> Signed-off-by: David Decotigny <decot@google.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
