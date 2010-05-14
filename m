From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] drivers/net: Remove unnecessary returns
 from void function()s
Date: Fri, 14 May 2010 00:19:45 -0700 (PDT)
Message-ID: <20100514.001945.52204757.davem@davemloft.net>
References: <1273769886.21514.72.camel@Joe-Laptop.home>
	<20100513.190953.233716325.davem@davemloft.net>
	<1273816980.1583.40.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56424
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755241Ab0ENHTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 03:19:38 -0400
In-Reply-To: <1273816980.1583.40.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 13 May 2010 23:03:00 -0700

> On Thu, 2010-05-13 at 19:09 -0700, David Miller wrote:
>> Ok, please remake this patch with those cases removed.
> 
> This patch removes from drivers/net/ all the unnecessary
> return; statements that precede the last closing brace of
> void functions.
> 
> It does not remove the returns that are immediately
> preceded by a label as gcc doesn't like that.
> 
> It also does not remove null void functions with return.
> 
> Done via:
> $ grep -rP --include=*.[ch] -l "return;\n}" net/ | \
>   xargs perl -i -e 'local $/ ; while (<>) { s/\n[ \t\n]+return;\n}/\n}/g; print; }'
> 
> with some cleanups by hand.
> 
> Compile tested x86 allmodconfig only.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks a lot Joe.
