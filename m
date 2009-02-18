From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 35/43] drivers/net/wan: fix warning: format not a
 string literal and no ...
Date: Tue, 17 Feb 2009 19:35:19 -0800 (PST)
Message-ID: <20090217.193519.162889859.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214214755.24377.57742.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59005
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754119AbZBRDff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 22:35:35 -0500
In-Reply-To: <20090214214755.24377.57742.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:48:07 +0100

> Impact: Use 'static const char[]' instead of 'static char[]'.
> 
> Fix this compilation warnings:
>   drivers/net/wan/lapbether.c: In function 'lapbeth_init_driver':
>   drivers/net/wan/lapbether.c:441: warning: format not a string literal and no format arguments
>   drivers/net/wan/z85230.c: In function 'z85230_init_driver':
>   drivers/net/wan/z85230.c:1782: warning: format not a string literal and no format arguments
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
