From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix ipv6_prefix_equal64_half mask
 conversion
Date: Wed, 16 Jan 2013 16:37:29 -0500 (EST)
Message-ID: <20130116.163729.1934084260354327196.davem@davemloft.net>
References: <1358371817-15378-1-git-send-email-fabio.baltieri@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net
To: fabio.baltieri@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358371817-15378-1-git-send-email-fabio.baltieri@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabio Baltieri <fabio.baltieri@linaro.org>
Date: Wed, 16 Jan 2013 22:30:17 +0100

> Fix the 64bit optimized version of ipv6_prefix_equal to convert the
> bitmask to network byte order only after the bit-shift.
> 
> The bug was introduced in:
> 
> 3867517 ipv6: 64bit version of ipv6_prefix_equal().
> 
> Signed-off-by: Fabio Baltieri <fabio.baltieri@linaro.org>

Applied, thanks.
