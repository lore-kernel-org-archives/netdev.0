From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxge: Fix wrong boolean operator {nodisc}
Date: Tue, 01 Feb 2011 12:30:12 -0800 (PST)
Message-ID: <20110201.123012.193709953.davem@davemloft.net>
References: <1296253817-7668-1-git-send-email-weil@mail.berlios.de>
	<FCA91A92EE52B041906A0358FC28FCC38EFBE64996@FRE1EXCH02.hq.exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weil@mail.berlios.de, Sivakumar.Subramani@exar.com,
	Sreenivasa.Honnur@exar.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jon.Mason@exar.com
To: Ramkrishna.Vepa@exar.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <FCA91A92EE52B041906A0358FC28FCC38EFBE64996@FRE1EXCH02.hq.exar.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
Date: Mon, 31 Jan 2011 23:26:40 -0800

>> This error is reported by cppcheck:
>> drivers/net/vxge/vxge-config.c:3693: warning: Mutual exclusion over ||
>> always evaluates to true. Did you intend to use && instead?
>> 
>> It looks like cppcheck is correct, so fix this. No test was run.
>> 
>> Signed-off-by: Stefan Weil <weil@mail.berlios.de>
...
> Fix looks good. Thanks!
> 
> Acked-by: Ram Vepa <ram.vepa@exar.com>

Thanks for reviewing, applied.
