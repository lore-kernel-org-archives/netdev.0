From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tcp: split tcp_ecn sysctl knob to distinguish between
 IPv4 and IPv6
Date: Mon, 31 Dec 2012 14:05:38 -0800
Message-ID: <20121231140538.6e55c82d@nehalam.linuxnetplumber.net>
References: <20121231173532.GA11700@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47954 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751090Ab2LaWHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 17:07:00 -0500
In-Reply-To: <20121231173532.GA11700@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Dec 2012 18:35:33 +0100
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> ECN could be more reliable when used with IPv6 (I don't have proofs). For
> people who want to try ECN with IPv6 but still have problems connecting
> to destinations because of broken IPv4 routers this switch allows one
> to enable ECN just for IPv6.
> 
> Perhaps ECN could be enabled by default in future.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Any new or modified sysctl should be documented in:
  Documentation/networking/ip-sysctl.txt
