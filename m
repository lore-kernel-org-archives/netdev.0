From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Subject: Re: [PATCH/RFC] [v2] TCP: use non-delayed ACK for congestion	control
 RTT
Date: Wed, 19 Dec 2007 10:28:35 +0000
Message-ID: <20071219102835.GE31508@nuim.ie>
References: <20071217134425.GD7409@nuim.ie> <20071218204022.GA8936@nuim.ie>
Reply-To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:58086 "EHLO mango.nuim.ie"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752138AbXLSK2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 05:28:31 -0500
Content-disposition: inline
Received: from boing.hamilton.local ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTP id <0JTA0013BL3GT1B0@mango.nuim.ie> for
 netdev@vger.kernel.org; Wed, 19 Dec 2007 10:28:28 +0000 (GMT)
In-reply-to: <20071218204022.GA8936@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, 18 Dec 2007, Gavin McCullagh wrote:

> The last attempt didn't take account of the situation where a timestamp
> wasn't available and tcp_clean_rtx_queue() has to feed both the RTO and the
> congestion avoidance.  This updated patch stores both RTTs, making the
> delayed one available for the RTO and the other (ca_seq_rtt) available for
> congestion control.

I forgot to include some data to show the difference this can make to the
RTT signal:

	http://www.hamilton.ie/gavinmc/linux/tcp_clean_rtx_queue.html

Gavin

