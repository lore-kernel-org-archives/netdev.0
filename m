From: Christoph Lameter <cl@linux.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 15:55:02 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904161553160.23632@qirst.com>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com> <49E78A79.6050604@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:43427 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757763AbZDPUCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 16:02:07 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6271682C28A
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 16:12:00 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yhzTRvZ42Wt4 for <netdev@vger.kernel.org>;
	Thu, 16 Apr 2009 16:12:00 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A69AA82C2D8
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 16:11:55 -0400 (EDT)
In-Reply-To: <49E78A79.6050604@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, Eric Dumazet wrote:

> Is it a bnx2 or tg3 driver ?

bnx2.

> It would be sane to always set on both machines :
> ethtool -C eth0 rx-usecs 0 rx-frames 1
> prior to your tests...

rx-usecs is set to 18 by default by the driver and rx-frames is set to 6.
We saw some funky behavior with rx-usecs 0 so we left the defaults.

But what does it matter? Just changing the kernel should not cause
increases in latency.

