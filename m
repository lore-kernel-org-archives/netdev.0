From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v2 1/3] ipvlan: Defer multicast / broadcast
 processing to a work-queue
Date: Fri, 01 May 2015 21:09:23 -0400 (EDT)
Message-ID: <20150501.210923.105876798516918879.davem@davemloft.net>
References: <1430331556-20242-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, dcbw@redhat.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbbEBBJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 21:09:26 -0400
In-Reply-To: <1430331556-20242-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Wed, 29 Apr 2015 11:19:16 -0700

> +			dev_queue_xmit(skb);
> +		} else {
> +			kfree_skb(skb);
>  		}
>  	}
> +	return;
>  }
>  

Please do not add trailing return statements to functions returning
void.
