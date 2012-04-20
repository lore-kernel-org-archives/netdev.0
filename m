From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/4 (v2)] stmmac: Move the mdio_register/_unregister
 in probe/remove
Date: Thu, 19 Apr 2012 20:09:11 -0400 (EDT)
Message-ID: <20120419.200911.266581260340706532.davem@davemloft.net>
References: <1334814502-29707-1-git-send-email-peppe.cavallaro@st.com>
	<1334814502-29707-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, francesco.virlinzi@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756595Ab2DTAJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 20:09:16 -0400
In-Reply-To: <1334814502-29707-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 19 Apr 2012 07:48:20 +0200

> From: Francesco Virlinzi <francesco.virlinzi@st.com>
> 
> This patch moves the mdio_register/_unregister in probe/remove
> functions and this also is required when hibernation on disk
> is done.
> 
> ---

Because you put the "---" delimiter here, the signoffs would have
been deleted from the commit log message when I apply this with GIT
tools.

I caught it this time, but you need to be more careful about things
like this, and I still contend that you are very sloppy in your
patch submissions and exhibit a low attention to detail.

Anyways, applied.

> v2: remove useless open_clk_dis label and do a simple tidy-up
> in the open function.
> 
> Signed-off-by: Francesco Virlinzi <francesco.virlinzi@st,com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st,com>
