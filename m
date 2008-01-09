From: David Miller <davem@davemloft.net>
Subject: Re: [ATM]: Check IP header validity in mpc_send_packet
Date: Wed, 09 Jan 2008 03:52:28 -0800 (PST)
Message-ID: <20080109.035228.236150477.davem@davemloft.net>
References: <20080109102745.GA29297@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@ftp.linux.org.uk,
	chas@cmf.nrl.navy.mil
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50700
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752519AbYAILw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 06:52:29 -0500
In-Reply-To: <20080109102745.GA29297@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 9 Jan 2008 21:27:45 +1100

> [ATM]: Check IP header validity in mpc_send_packet
> 
> Al went through the ip_fast_csum callers and found this piece of code
> that did not validate the IP header.  While root crashing the machine
> by sending bogus packets through raw or AF_PACKET sockets isn't that
> serious, it is still nice to react gracefully.
> 
> This patch ensures that the skb has enough data for an IP header and
> that the header length field is valid.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks for following up on this.
