From: David Miller <davem@davemloft.net>
Subject: Re: TCP cache performance
Date: Mon, 07 Jan 2008 17:57:48 -0800 (PST)
Message-ID: <20080107.175748.174400658.davem@davemloft.net>
References: <4782D06B.30706@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lachlan.andrew@gmail.com
To: virtualphtn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40318
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755037AbYAHB5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 20:57:49 -0500
In-Reply-To: <4782D06B.30706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Quetchenbach <virtualphtn@gmail.com>
Date: Mon, 07 Jan 2008 17:22:51 -0800

> This suggests that efforts to improve TCP performance should focus
> on cache usage rather than just processing time.

Thanks for reporting your data, but we very well know what the exact
problem is.

When we recover from loss, we touch thousands of packets freeing up
basically an entire window's worth.
