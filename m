From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_dbg_ratelimited: turn into no-op when !DEBUG
Date: Mon, 03 Aug 2015 21:59:00 -0700 (PDT)
Message-ID: <20150803.215900.915316341182067498.davem@davemloft.net>
References: <1438658773-3220-1-git-send-email-Jason@zx2c4.com>
	<1438660677.10829.1.camel@perches.com>
	<1438660941.10829.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jason@zx2c4.com, akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438660941.10829.3.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 03 Aug 2015 21:02:21 -0700

> On Mon, 2015-08-03 at 20:57 -0700, Joe Perches wrote:
>> On Tue, 2015-08-04 at 05:26 +0200, Jason A. Donenfeld wrote:
>> > This patch replaces calls to net_dbg_ratelimited when !DEBUG with
>> > no_printk, keeping with the idiom of all the other debug print helpers.
>> 
>> Makes sense, thanks Jason.
> 
> Perhaps better still would be to use if (0) no_printk so that
> the call and whatever argument calls the net_dbg_ratelimited
> makes are completely eliminated.

Agreed. Jason please respin your patch to work this way.
