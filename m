From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/15] irda/irnet: use noop_llseek
Date: Wed, 15 Sep 2010 19:31:25 -0700 (PDT)
Message-ID: <20100915.193125.149817205.davem@davemloft.net>
References: <1284495763-7506-1-git-send-email-arnd@arndb.de>
	<1284495763-7506-9-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, samuel@sortiz.org,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284495763-7506-9-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 14 Sep 2010 22:22:36 +0200

> There may be applications trying to seek
> on the irnet character device, so we should
> use noop_llseek to avoid returning an error
> when the default llseek changes to no_llseek.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
