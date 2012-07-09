From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev/phy: Fixup lockdep warnings in mdio-mux.c
Date: Mon, 09 Jul 2012 00:13:08 -0700 (PDT)
Message-ID: <20120709.001308.1467096850382631360.davem@davemloft.net>
References: <1341439576-1413-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	david.daney@cavium.com
To: ddaney.cavm@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341439576-1413-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney.cavm@gmail.com>
Date: Wed,  4 Jul 2012 15:06:16 -0700

> From: David Daney <david.daney@cavium.com>
> 
> With lockdep enabled we get:
 ...
> This is a false positive, since we are indeed using 'nested' locking,
> we need to use mutex_lock_nested().
> 
> Now in theory we can stack multiple MDIO multiplexers, but that would
> require passing the nesting level (which is difficult to know) to
> mutex_lock_nested().  Instead we assume the simple case of a single
> level of nesting.  Since these are only warning messages, it isn't so
> important to solve the general case.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Applied to 'net', thanks.
