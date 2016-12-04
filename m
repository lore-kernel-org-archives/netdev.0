From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: dcb: set error code on failures
Date: Sat, 03 Dec 2016 23:55:03 -0500 (EST)
Message-ID: <20161203.235503.558375941675604872.davem@davemloft.net>
References: <1480772948-7087-1-git-send-email-bianpan201602@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bianpan2016@163.com
To: bianpan201602@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480772948-7087-1-git-send-email-bianpan201602@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan201602@163.com>
Date: Sat,  3 Dec 2016 21:49:08 +0800

> From: Pan Bian <bianpan2016@163.com>
> 
> In function dcbnl_cee_fill(), returns the value of variable err on
> errors. However, on some error paths (e.g. nla put fails), its value may
> be 0. It may be better to explicitly set a negative errno to variable
> err before returning.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188881
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied, thanks.
