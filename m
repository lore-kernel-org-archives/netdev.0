From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net: drop duplicate assignment in request_sock
Date: Sun, 26 Mar 2006 17:39:18 -0800 (PST)
Message-ID: <20060326.173918.15234485.davem@davemloft.net>
References: <20060326122410.GG4053@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, nkiesel@tbdnetworks.com, acme@conectiva.com.br,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751535AbWC0Bj1@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060326122410.GG4053@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sun, 26 Mar 2006 14:24:10 +0200

> From: Norbert Kiesel <nkiesel@tbdnetworks.com>
> 
> Just noticed that request_sock.[ch] contain a useless assignment of
> rskq_accept_head to itself.  I assume this is a typo and the 2nd one
> was supposed to be _tail.  However, setting _tail to NULL is not
> needed, so the patch below just drops the 2nd assignment.
> 
> Signed-Off-By: Norbert Kiesel <nkiesel@tbdnetworks.com>
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks.
