From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: idt77105: fix fetch_stats() result
Date: Fri, 21 Jan 2011 16:24:32 -0800 (PST)
Message-ID: <20110121.162432.77330574.davem@davemloft.net>
References: <1295602987-11688-1-git-send-email-segoon@openwall.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: segoon@openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295602987-11688-1-git-send-email-segoon@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasiliy Kulikov <segoon@openwall.com>
Date: Fri, 21 Jan 2011 12:43:07 +0300

> copy_to_user() used PRIV(dev)->stats instead of local stats variable.
> Zero stats were returned to user in case of (zero != 0), also memcpy()
> was pointless.
> 
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>

Applied, thanks.
