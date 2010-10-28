From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/unix: Allow Unix sockets to be treated like
 normal files
Date: Wed, 27 Oct 2010 19:32:12 -0700 (PDT)
Message-ID: <20101027.193212.193709254.davem@davemloft.net>
References: <1288232669-8927-1-git-send-email-x@jeffhansen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: x@jeffhansen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50362
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932726Ab0J1Cbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 22:31:49 -0400
In-Reply-To: <1288232669-8927-1-git-send-email-x@jeffhansen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: x@jeffhansen.com
Date: Thu, 28 Oct 2010 02:24:29 +0000

> Resent.  Is there anything else I need to do for this patch to get reviewed
> and/or merged?  Any comments by anyone?

I don't like this idea at all.

I remember there is a reason why similar things are not allowed for
sockets, it causes all sorts of problems although I forget the exact
details.

Take a look at net/socket.c:sock_no_open(), for example.

