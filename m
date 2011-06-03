From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: inet_diag insufficient validation?
Date: Thu, 02 Jun 2011 20:50:11 -0400
Message-ID: <1307062211.4292.2.camel@dan>
References: <1306942849.3150.10.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org, security@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:57017 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411Ab1FCAuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 20:50:20 -0400
In-Reply-To: <1306942849.3150.10.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-01 at 11:40 -0400, Dan Rosenberg wrote:

> Finally, I can't seem to find any validation that the reported length of
> the netlink message header doesn't exceed the skb length, as checked in
> some other netlink receive functions, which could result in reading
> beyond the bounds of the socket data.  I could just be missing something
> here though.
> 

And for the second time, I was missing something - this validation
happens in netlink_rcv_skb().

That leaves the infinite loop in bytecode auditing, which I've confirmed
via reproducer.

-Dan

