From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] skbuff: use kfree_skb() instead of kfree()
Date: Wed, 20 Jul 2011 10:25:49 +0300
Message-ID: <20110720072549.GG6445@shale.localdomain>
References: <20110720072343.GF6445@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Shirley Ma <xma@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48672 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080Ab1GTH1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 03:27:45 -0400
Content-Disposition: inline
In-Reply-To: <20110720072343.GF6445@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Crap.  Sorry, I shouldn't have sent that.  We shouldn't return the
freed "n" here.  I'll send a v2 shortly.

regards,
dan carpenter

