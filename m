From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 25/43] drivers/net/pcmcia: fix warning: format not a
 string literal and no ...
Date: Tue, 17 Feb 2009 17:39:21 -0800 (PST)
Message-ID: <20090217.173921.85144693.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214213849.24377.87932.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47207
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755754AbZBRBjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:39:37 -0500
In-Reply-To: <20090214213849.24377.87932.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:39:23 +0100

> Impact: Use 'static const char[]' instead of 'static char[]' and while
> being at it prefix the message with KERN_INFO.
> 
> Fix this warnings:
>   drivers/net/pcmcia/axnet_cs.c:1716: warning: format not a string literal and no format arguments
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
