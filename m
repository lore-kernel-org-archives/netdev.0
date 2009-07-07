From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [patch] ipv6: correct return on ipv6_rcv() packet drop
Date: Tue, 7 Jul 2009 18:50:15 +0930
Message-ID: <20090707185015.391c893f.lk-netdev@lk-netdev.nosense.org>
References: <20090707065624.ee55809e.lk-netdev@lk-netdev.nosense.org>
	<20090706.180945.113737445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.adam.net.au ([202.136.110.249]:38772 "EHLO
	smtp3.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694AbZGGJUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 05:20:24 -0400
In-Reply-To: <20090706.180945.113737445.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Mon, 06 Jul 2009 18:09:45 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
> Date: Tue, 7 Jul 2009 06:56:24 +0930
> 
> > The routine ipv6_rcv() uses magic number 0 for a return when it drops a
> > packet. This corresponds to NET_RX_SUCCESS, which is obviously
> > incorrect. Correct this by using NET_RX_DROP instead.
> > 
> > ps. It isn't exactly clear who the IPv6 maintainers are, apologies if
> > I've missed any.
> > 
> > Signed-off-by: Mark Smith <markzzzsmith@yahoo.com.au>
> 
> Applied.

Today I came across this earlier partial version of what I
independently identified and submitted, so I shouldn't get full credit
for it:

http://lkml.indiana.edu/hypermail/linux/kernel/0804.1/2393.html

Regards,
Mark.
