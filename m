From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 v2] isdn: hisax: set error code on failure
Date: Mon, 05 Dec 2016 15:04:54 -0500 (EST)
Message-ID: <20161205.150454.1689858963074461020.davem@davemloft.net>
References: <1480848211-15969-1-git-send-email-bianpan201603@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, isdn@linux-pingi.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bianpan2016@163.com
To: bianpan201603@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480848211-15969-1-git-send-email-bianpan201603@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan201603@163.com>
Date: Sun,  4 Dec 2016 18:43:31 +0800

> From: Pan Bian <bianpan2016@163.com>
> 
> In function hfc4s8s_probe(), the value of return variable err should be
> negative on failures. However, when the call to request_region() returns
> NULL, the value of err is 0. This patch fixes the bug, assigning
> "-EBUSY" to err on the path that request_region() fails.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188931
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied.
