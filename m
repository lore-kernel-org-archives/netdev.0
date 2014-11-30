From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sh_eth: Fix skb alloc size and alignment adjust
 rule.
Date: Sat, 29 Nov 2014 21:12:12 -0800 (PST)
Message-ID: <20141129.211212.2189096129383310983.davem@davemloft.net>
References: <1417088040-32144-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au, magnus.damm@gmail.com,
	linux-sh@vger.kernel.org
To: ykaneko0929@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1417088040-32144-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Date: Thu, 27 Nov 2014 20:34:00 +0900

> From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> 
> In the current driver, allocation size of skb does not care the alignment
> adjust after allocation.
> And also, in the current implementation, buffer alignment method by
> sh_eth_set_receive_align function has a bug that this function displace
> buffer start address forcedly when the alignment is corrected.
> In the result, tail of the skb will exceed allocated area and kernel panic
> will be occurred.
> This patch fix this issue.
> 
> Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

Applied.
