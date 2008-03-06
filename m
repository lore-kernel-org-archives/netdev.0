From: David Miller <davem@davemloft.net>
Subject: Re: [patch (for 2.6.25?) 2/2] RxRPC: fix rxrpc_recvmsg()'s
 returning of msg_name
Date: Wed, 05 Mar 2008 18:54:10 -0800 (PST)
Message-ID: <20080305.185410.76617387.davem@davemloft.net>
References: <200803042256.m24Muogl001357@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhowells@redhat.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42278
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753886AbYCFCyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 21:54:11 -0500
In-Reply-To: <200803042256.m24Muogl001357@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 04 Mar 2008 14:56:49 -0800

> Fix rxrpc_recvmsg() to return msg_name correctly.  We shouldn't overwrite the
> *msg struct, but should rather write into msg->msg_name (there's a '&' unary
> operator that shouldn't be there).
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
