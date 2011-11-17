From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] stmmac: remove spin_lock in stmmac_ioctl.
Date: Thu, 17 Nov 2011 03:14:30 -0500 (EST)
Message-ID: <20111117.031430.491721529337695679.davem@davemloft.net>
References: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
	<1321516682-32208-4-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, francesco.virlinzi@st.com,
	srinivas.kandagatla@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755661Ab1KQIOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 03:14:36 -0500
In-Reply-To: <1321516682-32208-4-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 17 Nov 2011 08:58:01 +0100

> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> This patch removes un-needed spin_lock in stmmac_ioctl while reading and
> writing mdio registers. While holding spin_lock the code must be
> atomic, which is not true in this case as both mdiobus_read and writes
> have mutex locks.
> 
> Without this patch reading mdio registers via mii-tool results in below
> BUG:
> mii-tool -vvv eth0"
> Using SIOCGMIIPHY=0x8947
> BUG: sleeping function called from invalid context at kernel/mutex.c:287
 ...
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
