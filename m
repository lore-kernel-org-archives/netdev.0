From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netconsole: avoid a crash with multiple sysfs
 writers
Date: Tue, 03 Sep 2013 22:11:15 -0400 (EDT)
Message-ID: <20130903.221115.3505404468610766.davem@davemloft.net>
References: <20130809062405.GA8031@neilslaptop.think-freely.org>
	<1377860386-8494-1-git-send-email-alonid@postram.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	nhorman@tuxdriver.com
To: alonid@postram.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377860386-8494-1-git-send-email-alonid@postram.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Aloni <alonid@postram.com>
Date: Fri, 30 Aug 2013 13:59:46 +0300

> When my 'ifup eth' script was fired multiple times and ran concurrent on
> my laptop, for some obscure /etc scripting reason, it was revealed
> that the store_enabled() function in netconsole doesn't handle it nicely,
> as recorded by the Oops below (a syslog paste, but not mangled too much
> to prevent from discerning the traceback).
> 
> On Linux 3.10.4, this patch seeks to remedy the problem, and it has been
> running stable on my laptop for a few days.
 ...
> Signed-off-by: Dan Aloni <alonid@postram.com>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks.
