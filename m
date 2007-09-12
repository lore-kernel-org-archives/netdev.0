From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 3/6] [IPROUTE2]: Update pkt_sched.h (to resemble the
 kernel one)
Date: Wed, 12 Sep 2007 13:02:51 +0200
Message-ID: <20070912130251.2ac8060e@oldman>
References: <1189592054.26927.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59986 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965805AbXILLCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 07:02:12 -0400
In-Reply-To: <1189592054.26927.24.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Sep 2007 12:14:14 +0200
Jesper Dangaard Brouer <jdb@comx.dk> wrote:

> commit ef065a43b8900fbc0763eac0fa0a9a8a00c8aaa2
> Author: Jesper Dangaard Brouer <hawk@comx.dk>
> Date:   Tue Sep 11 16:17:46 2007 +0200
> 
>     [IPROUTE2]: Update pkt_sched.h (to resemble the kernel one)
>     
>      Extend the tc_ratespec struct, with two parameters: 1) "cell_align"
>      that allow adjusting the alignment of the rate table. 2) "overhead"
>      that allow adding a packet overhead before the lookup in the kernel.
>     
>      This is done in order to, add support to changing the rate table to
>      use the upper-boundry L2T (length to time) value. Currently we use the
>      lower-boundry, which result in under-estimating the actual bandwidth
>      usage.
>     
>     Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> 

Okay, but don't need a special patch to do it. I perodically sync
up the headers before each release.
