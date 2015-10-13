From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] atm: iphase: fix misleading indention
Date: Mon, 12 Oct 2015 19:56:56 -0700 (PDT)
Message-ID: <20151012.195656.558210406749852516.davem@davemloft.net>
References: <1444506439-10414-1-git-send-email-theidsieck@leenox.de>
	<1444506439-10414-3-git-send-email-theidsieck@leenox.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: theidsieck@leenox.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444506439-10414-3-git-send-email-theidsieck@leenox.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tillmann Heidsieck <theidsieck@leenox.de>
Date: Sat, 10 Oct 2015 21:47:19 +0200

> Fix a smatch warning:
> drivers/atm/iphase.c:1178 rx_pkt() warn: curly braces intended?
> 
> The code is correct, the indention is misleading. In case the allocation
> of skb fails, we want to skip to the end.
> 
> Signed-off-by: Tillmann Heidsieck <theidsieck@leenox.de>

Applied to net-next.
