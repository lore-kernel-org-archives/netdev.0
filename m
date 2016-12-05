From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: caif: remove ineffective check
Date: Mon, 05 Dec 2016 14:49:12 -0500 (EST)
Message-ID: <20161205.144912.1032798616829972627.davem@davemloft.net>
References: <1480824944-3439-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, sergei.shtylyov@cogentembedded.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bianpan2016@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480824944-3439-1-git-send-email-bianpan2016@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan2016@163.com>
Date: Sun,  4 Dec 2016 12:15:44 +0800

> The check of the return value of sock_register() is ineffective.
> "if(!err)" seems to be a typo. It is better to propagate the error code
> to the callers of caif_sktinit_module(). This patch removes the check
> statment and directly returns the result of sock_register().
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188751
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied.
