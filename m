From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bna: add missing iounmap() on error in bnad_init()
Date: Mon, 13 May 2013 12:55:34 -0700 (PDT)
Message-ID: <20130513.125534.1964357000854694095.davem@davemloft.net>
References: <CAPgLHd_6i7LkoHB8GpcwF0=3ZD=Cs9Cd0JryPibMLS_j1XmRKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, sergei.shtylyov@cogentembedded.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab3EMTzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 15:55:35 -0400
In-Reply-To: <CAPgLHd_6i7LkoHB8GpcwF0=3ZD=Cs9Cd0JryPibMLS_j1XmRKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 13 May 2013 22:26:06 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Add the missing iounmap() before return from bnad_init()
> in the error handling case.
> Introduced by commit 01b54b1451853593739816a392485c4e2bee7dda
> (bna: tx rx cleanup fix).
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
