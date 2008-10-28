From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] misc: replace NIP6_FMT with %p6 format specifier
Date: Tue, 28 Oct 2008 16:06:54 -0700 (PDT)
Message-ID: <20081028.160654.252305278.davem@davemloft.net>
References: <1225223629.11483.41.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38506
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753374AbYJ1XHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 19:07:17 -0400
In-Reply-To: <1225223629.11483.41.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Tue, 28 Oct 2008 12:53:49 -0700

> The iscsi_ibft.c changes are almost certainly a bugfix as the
> pointer 'ip' is a u8 *, so they never print the last 8 bytes
> of the IPv6 address, and the eight bytes they do print have
> a zero byte with them in each 16-bit word.
> 
> Other than that, this should cause no difference in functionality.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks Harvey.
