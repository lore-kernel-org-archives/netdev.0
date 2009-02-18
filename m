From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 32/43] drivers/net/tulip: fix warning: format not a
 string literal and no ...
Date: Tue, 17 Feb 2009 19:35:02 -0800 (PST)
Message-ID: <20090217.193502.194880051.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214214632.24377.15197.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58996
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752346AbZBRDfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 22:35:18 -0500
In-Reply-To: <20090214214632.24377.15197.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:46:59 +0100

> Impact: Use 'static const char[]' instead of 'static char[]' and while
> being at it add a KERN_INFO prefix.
> 
> Fix this warning:
>   drivers/net/tulip/de4x5.c: In function 'de4x5_hw_init':
>   drivers/net/tulip/de4x5.c:1268: warning: format not a string literal and no format arguments
>   drivers/net/tulip/winbond-840.c: In function 'w840_init':
>   drivers/net/tulip/winbond-840.c:1666: warning: format not a string literal and no format arguments
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
