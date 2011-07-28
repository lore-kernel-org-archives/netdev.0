From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: special handling before ndo_start_xmit() been invoked
Date: Thu, 28 Jul 2011 21:37:59 +0200
Message-ID: <20110728193758.GA2156@minipsycho>
References: <201107271848349537853@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: "jiangtao.jit" <jiangtao.jit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46570 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754677Ab1G1TiC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2011 15:38:02 -0400
Content-Disposition: inline
In-Reply-To: <201107271848349537853@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What would you want to achieve with that?

Wed, Jul 27, 2011 at 12:48:37PM CEST, jiangtao.jit@gmail.com wrote:
>Hi all:
>
>in struct net_device
>there is a function pointer    rx_handler_func_t __rcu	*rx_handler
>it's very convenient to register a function in an externel module
>and do some special handlings
>
>so i think what about to add an tx_handler_func
>before        ndo_start_xmit() been invoked
>and do some special things before transmit
>
>is it necessary or there is already some other better methods to achieve this goal ?
>Thank you all
>
>-------
>2011-07-27 
>jiangtao.jit 
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
