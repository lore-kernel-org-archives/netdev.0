From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] stmmac: correct mc_filter local variable in
 set_filter and set_mac_addr call
Date: Fri, 10 Oct 2014 14:48:41 -0400 (EDT)
Message-ID: <20141010.144841.1103657696761242978.davem@davemloft.net>
References: <1412867436-22153-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vbridger@altera.com
To: vbridger@opensource.altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412867436-22153-1-git-send-email-vbridger@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vince Bridgers <vbridger@opensource.altera.com>
Date: Thu, 9 Oct 2014 10:10:36 -0500

> Testing revealed that the local variable mc_filter was dimensioned
> incorrectly for all possible configurations and get_mac_addr should
> have been set_mac_addr (a typo). Make sure mc_filter is dimensioned
> to 8 32-bit unsigned longs - the largest size of the Synopsys
> multicast filter register set.
> 
> Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>

Applied, thanks vince.
