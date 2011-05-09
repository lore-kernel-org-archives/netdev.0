From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] tulip: logging cleanups
Date: Mon, 09 May 2011 11:47:06 -0700 (PDT)
Message-ID: <20110509.114706.189685729.davem@davemloft.net>
References: <cover.1304733889.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1304733889.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Fri,  6 May 2011 19:08:41 -0700

> Joe Perches (4):
>   tulip: xircom_cb: Convert #ifdef DEBUG blocks and enter/leave uses
>   tulip: Convert printks to netdev_<level>
>   tulip: Convert uses of KERN_DEBUG
>   tulip: Use pr_<level> where appropriate

With the advent of the function tracer, those silly function entry/exit
logging things are entirely superfluous.

They make the code look ugly too.

So you have my approval to just kill those things off entirely.

Please do that and respin this patch set, thanks Joe!
