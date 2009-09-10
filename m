From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Thu, 10 Sep 2009 17:36:15 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909101728250.27669@V090114053VZO-1>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1> <4AA7E082.90807@gmail.com>
 <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1> <4AA963A4.5080509@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:34155 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752376AbZIJVhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 17:37:33 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 68B3B82C14A
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 17:38:39 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZuoCsUxdAhqP for <netdev@vger.kernel.org>;
	Thu, 10 Sep 2009 17:38:34 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 98EE682C237
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 17:38:32 -0400 (EDT)
In-Reply-To: <4AA963A4.5080509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Sep 2009, Eric Dumazet wrote:

> On the receiver I did this to trace the latency messages only
>
> # tcpdump -i eth0 not host 239.0.192.2 and port 9002 -n

You do not show the multicast traffic. The latency timestamps requests are
send unicast and at larger intervals. About one per second per mc channel.

