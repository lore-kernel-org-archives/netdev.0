From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] cadence: Add LSO support.
Date: Mon, 07 Nov 2016 20:38:46 -0500 (EST)
Message-ID: <20161107.203846.734910693756417486.davem@davemloft.net>
References: <1477397130-24250-1-git-send-email-rafalo@cadence.com>
        <1478259618-23474-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: rafalo@cadence.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478259618-23474-1-git-send-email-rafalo@cadence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafal Ozieblo <rafalo@cadence.com>
Date: Fri, 4 Nov 2016 11:40:18 +0000

> +		if (IPPROTO_UDP == (((struct iphdr *)skb_network_header(skb))->protocol))

This is simply "ip_hdr(skb)->protocol", please use it everywhere you
have this ugly cast thing in this change.

Thanks.
