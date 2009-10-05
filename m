From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCPCT+1: initial SYN exchange with SYNACK data
Date: Mon, 05 Oct 2009 01:45:58 -0700 (PDT)
Message-ID: <20091005.014558.48061546.davem@davemloft.net>
References: <20091005.002719.146534039.davem@davemloft.net>
	<4AC9A714.7060903@gmail.com>
	<4AC9AA3E.2090001@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758349AbZJEIqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 04:46:04 -0400
In-Reply-To: <4AC9AA3E.2090001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Mon, 05 Oct 2009 04:11:42 -0400

> Given that size is now a concern, would a single kref pointer with a
> u16 field for flags be acceptable?  I could bury the rest in the
> kref block.
> 
> Would that be acceptable without a config option?

Then we'll eat an atomic operation every connect() or something
like that?

That's bad too.  We're trying desperately to remove as many
atomic operations as possible from the socket paths.

Compress your state, really compress it, don't just externalize
it somewhere else in exchange for a different cost.
