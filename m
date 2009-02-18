From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/43] drivers/net/e2100.c: fix sparse warning: symbol
 shadows an earlier one
Date: Tue, 17 Feb 2009 17:21:27 -0800 (PST)
Message-ID: <20090217.172127.252722025.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214211203.23489.80420.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47814
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753460AbZBRBVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:21:43 -0500
In-Reply-To: <20090214211203.23489.80420.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:12:10 +0100

> Impact: Remove redundant inner scope variable and while being at it
> make use of ARRAY_SIZE instead of a hardcoded number.
> 
> Fix this sparse warning:
>   drivers/net/e2100.c:219:56: warning: symbol 'i' shadows an earlier one
>   drivers/net/e2100.c:181:13: originally declared here
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
