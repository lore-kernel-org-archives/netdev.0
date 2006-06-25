From: Paul Mackerras <paulus@samba.org>
Subject: Re: [patch 1/6] ppp_async hang fix
Date: Sun, 25 Jun 2006 21:44:09 +1000
Message-ID: <17566.30473.399299.975192@cargo.ozlabs.ibm.com>
References: <200606250847.k5P8lS0L020897@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41401 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S932390AbWFYLpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2006 07:45:31 -0400
To: akpm@osdl.org
In-Reply-To: <200606250847.k5P8lS0L020897@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org writes:

> From: <xeb@mail.ru>
> 
> Adapted from  http://bugzilla.kernel.org/show_bug.cgi?id=6530
> 
> Reschedule the async Tx tasklet if the transmit queue was full.
> 
> Cc: Paul Mackerras <paulus@samba.org>
> 
> [akpm: submitted before, discussion petered off inconclusively]

NACK.

This "fix" is inefficient and also unnecessary now that I have found
and fixed the real problem, which was in n_tty.c.  

Paul.
