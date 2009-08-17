From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Mon, 17 Aug 2009 16:46:29 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908171642500.20399@gentwo.org>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org> <4A89C026.4030402@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
To: Nivedita Singhvi <niv@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:41547 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752594AbZHQUqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 16:46:51 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 53C9E82C51C
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 16:46:57 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tyOhirbski+2 for <netdev@vger.kernel.org>;
	Mon, 17 Aug 2009 16:46:51 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3EB4B82C4B3
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 16:46:51 -0400 (EDT)
In-Reply-To: <4A89C026.4030402@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Aug 2009, Nivedita Singhvi wrote:

> Is there any chance this is getting dropped at qdisc?
> Can you check with tc?

I checked and the counter there is zero.

:/home/clameter# tc -s qdisc show

qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1
1 1 1 1 1
 Sent 3042712708 bytes 8896862 pkt (dropped 0, overlimits 0 requeues 56303)
 rate 0bit 0pps backlog 0b 0p requeues 56303




