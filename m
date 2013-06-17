From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next 5/5] staging/rtl8192u: convert skb->tail into
 skb_tail_pointer(skb)
Date: Mon, 17 Jun 2013 15:45:29 -0700
Message-ID: <20130617224529.GA28118@kroah.com>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
 <4e2318187b15be4d81c3b03cd0337506c7008bb8.1371200138.git.yamahata@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	devel@driverdev.osuosl.org
To: Isaku Yamahata <yamahata@valinux.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:41928 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518Ab3FQWpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 18:45:30 -0400
Content-Disposition: inline
In-Reply-To: <4e2318187b15be4d81c3b03cd0337506c7008bb8.1371200138.git.yamahata@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 14, 2013 at 05:58:35PM +0900, Isaku Yamahata wrote:
> The change set of 7a884dc "[SK_BUFF]: Convert skb->tail to sk_buff_data_t"
> converted skb->tail from pointer into sk_buff_data_t.
> Thus skb->tail is not always pointer, the area pointed by skb->tail
> should be accessed via skb_tail_pointer().
> 
> Found by inspection. Compile tested only.

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
