From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 37/43] drivers/net/wireless: fix sparse warning:
 context imbalance
Date: Tue, 17 Feb 2009 19:35:29 -0800 (PST)
Message-ID: <20090217.193529.238038987.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214214833.24377.6182.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59011
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754685AbZBRDfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 22:35:45 -0500
In-Reply-To: <20090214214833.24377.6182.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:48:44 +0100

> Impact: Attribute function with __acquires(...) resp. __releases(...).
> 
> Fix this sparse warnings:
>   drivers/net/wireless/strip.c:955:21: warning: context imbalance in 'strip_seq_start' - wrong count at exit
>   drivers/net/wireless/strip.c:975:13: warning: context imbalance in 'strip_seq_stop' - unexpected unlock
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
