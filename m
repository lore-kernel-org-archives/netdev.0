From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: driver: stmicro: Remove some useless the lock
 protection
Date: Sat, 24 May 2014 23:33:45 -0400 (EDT)
Message-ID: <20140524.233345.1406269413034915848.davem@davemloft.net>
References: <20140523.160945.226886017757584215.davem@davemloft.net>
	<1400982824-3871-1-git-send-email-Wei.Yang@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Wei.Yang@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400982824-3871-1-git-send-email-Wei.Yang@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <Wei.Yang@windriver.com>
Date: Sun, 25 May 2014 09:53:44 +0800

> From: Yang Wei <Wei.Yang@windriver.com>
> 
> kernel always invokes a pair of rtnl_lock adn rtnl_unlock to
> protect dev_ethtool(), so its not neccessary to invoke spin_lock/unlock
> in ethtool_ops.
> 
> Signed-off-by: Yang Wei <Wei.Yang@windriver.com>

Applied to net-next, thanks.
