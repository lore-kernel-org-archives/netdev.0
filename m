From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 10:00:06 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908250958540.28552@gentwo.org>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
 <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908241334230.30487@gentwo.org> <4A930DEF.5000008@gmail.com>
 <alpine.DEB.1.10.0908250945460.5972@gentwo.org> <4A93EB9B.5020600@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.ultrahosting.com ([74.213.175.253]:53881 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751152AbZHYOAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 10:00:09 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 00CB682D000
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 10:01:04 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mJ0VhojqeM1P for <netdev@vger.kernel.org>;
	Tue, 25 Aug 2009 10:01:03 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 494BF82D002
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 10:00:59 -0400 (EDT)
In-Reply-To: <4A93EB9B.5020600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Aug 2009, Eric Dumazet wrote:

> Please hold on, I would like to fully understand what's happening,
> and test the patch :)

Ok. It would be good if the drops would also be somehow noted by the UDP
subsystem (one should see something with netstat -su) and may be even the
socket. I see a drops column in /proc/net/udp. rx_drops, tx_drops?
