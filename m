From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next - trivial] drivers/net: Remove address use
 from assignments of function pointers
Date: Wed, 25 Aug 2010 15:35:57 -0700 (PDT)
Message-ID: <20100825.153557.28797570.davem@davemloft.net>
References: <1282623603-31052-1-git-send-email-joe@perches.com>
	<1282623603-31052-2-git-send-email-joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44888
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752670Ab0HYWfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 18:35:41 -0400
In-Reply-To: <1282623603-31052-2-git-send-email-joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 23 Aug 2010 21:20:03 -0700

> "foo = &function" is more commonly written "foo = function"
> 
> Done with coccinelle script:
 ...
> drivers/net/tehuti.c used a function and struct with the
> same name, the function was renamed.
> 
> Compile tested x86 only.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.
