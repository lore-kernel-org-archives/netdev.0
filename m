From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: switchdev: don't abort unsupported operations
Date: Sat, 11 Jul 2015 21:30:35 -0700 (PDT)
Message-ID: <20150711.213035.143328784683068826.davem@davemloft.net>
References: <1436572138-16542-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com, jiri@resnulli.us,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436572138-16542-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 10 Jul 2015 19:48:58 -0400

> There is no need to abort attribute setting or object addition, if the
> prepare phase returned operation not supported.
> 
> Thus, abort these two transactions only if the error is not -EOPNOTSUPP.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks.
