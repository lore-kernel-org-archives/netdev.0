From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] eicon: Fixed checkpatch warning
Date: Sun, 10 Mar 2013 18:02:18 -0400 (EDT)
Message-ID: <20130310.180218.753487547136940085.davem@davemloft.net>
References: <1362918876-18694-1-git-send-email-hodea_andreea@yahoo.com>
	<20130310.165613.427736360718722534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, hodea_andreea@yahoo.com
To: andreea.cristina.hodea@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130310.165613.427736360718722534.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Sun, 10 Mar 2013 16:56:13 -0400 (EDT)

> From: Andreea Hodea <andreea.cristina.hodea@gmail.com>
> Date: Sun, 10 Mar 2013 14:34:36 +0200
> 
>> drivers/isdn/hardware/eicon/diva_didd.c:32:6: warning: symbol
>> 'DRIVERRELEASE_DIDD' was not declared. Should it be static?
>> 
>> Signed-off-by: Andreea Hodea <hodea_andreea@yahoo.com>
> 
> Applied, thanks.

I had to revert, did you even try to compile the driver after
this change?

The symbol is refenced by DbgRegister() calls in diddfunc.c, and
a very simple grep would have shown that to you.

Please do not just blindly try to fix checkpatch warnings.
