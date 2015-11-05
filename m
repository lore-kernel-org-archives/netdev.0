From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: remove unneeded phy_iface variable
Date: Thu, 05 Nov 2015 00:30:15 -0500 (EST)
Message-ID: <20151105.003015.45063597738858813.davem@davemloft.net>
References: <1446667692-6182-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446667692-6182-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Date: Wed,  4 Nov 2015 21:08:12 +0100

> The variable phy_iface is double-initialized and finally is not necessary
> at all.
> 
> Reported-by: coverity (CID 1271141)
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>

The value is used in two locations, so having it computed once in a
variable is useful.

Please just eliminate the double assignment.
