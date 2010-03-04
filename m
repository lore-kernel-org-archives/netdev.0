From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: fix hot plug removal crash
Date: Thu, 04 Mar 2010 00:39:46 -0800 (PST)
Message-ID: <20100304.003946.228300497.davem@davemloft.net>
References: <20100303194947.31628.5933.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, wenxiong@us.ibm.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36132
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751469Ab0CDIj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 03:39:28 -0500
In-Reply-To: <20100303194947.31628.5933.stgit@speedy5.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 03 Mar 2010 11:49:47 -0800

> From: Divy Le Ray <divy@chelsio.com>
> 
> queue restart tasklets need to be stopped after napi handlers are stopped
> since the latter can restart them.  So stop them after stopping napi.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
