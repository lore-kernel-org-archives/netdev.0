From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30 4/4] cxgb3: Fix EEH final recovery attempt
Date: Mon, 20 Apr 2009 02:08:34 -0700 (PDT)
Message-ID: <20090420.020834.105105859.davem@davemloft.net>
References: <20090417222127.8569.59426.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59078
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754886AbZDTJIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 05:08:42 -0400
In-Reply-To: <20090417222127.8569.59426.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Fri, 17 Apr 2009 15:21:27 -0700

> EEH attempts to recover up 6 times.
> The last attempt leaves all the ports and adapter down.hen
> The driver is then unloaded, bringing the adapter down again
> unconditionally. The unload will hang.
> Check if the adapter is already down before trying to bring it down again.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
