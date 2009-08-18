From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Mon, 17 Aug 2009 20:25:03 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908172024380.29958@gentwo.org>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
 <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	Eric Dumazet <dada1@cosmosbay.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:40646 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755380AbZHRAZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 20:25:20 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4FE7D82C804
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 20:25:27 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YiOsN9zxzFMs for <netdev@vger.kernel.org>;
	Mon, 17 Aug 2009 20:25:21 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 875D182C3C5
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 20:25:21 -0400 (EDT)
In-Reply-To: <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Aug 2009, Sridhar Samudrala wrote:

> The first 3 are rx stats and the last one is a tx stat.
> Anyway, only the first field(total packets received) seems to be non-zero
> in your softnet_stat output on both sender and receiver.
> So it is possible that there is some other place in the stack where the packets
> are gettting dropped but not counted.

Is the driver responsible? I noticed no rx_drop++ in there.

