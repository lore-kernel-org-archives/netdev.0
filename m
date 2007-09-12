From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 4/6] [IPROUTE2]: Overhead calculation is now done in the
 kernel
Date: Wed, 12 Sep 2007 13:05:09 +0200
Message-ID: <20070912130509.0a6dea32@oldman>
References: <1189592079.26927.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35069 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759933AbXILLE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 07:04:27 -0400
In-Reply-To: <1189592079.26927.25.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Sep 2007 12:14:39 +0200
Jesper Dangaard Brouer <jdb@comx.dk> wrote:

> commit 07a74a2613440fc1a68d0faa7235ed7027532d78
> Author: Jesper Dangaard Brouer <hawk@comx.dk>
> Date:   Tue Sep 11 16:59:58 2007 +0200
> 
>     [IPROUTE2]: Overhead calculation is now done in the kernel.
>     
>     The only current user is HTB. HTB overhead argument is now passed on
>     to the kernel (in the struct tc_ratespec). Also correct the data
>     types.
>     
>     Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

How is this binary compatable with older kernels?
