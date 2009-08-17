From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Mon, 17 Aug 2009 13:40:06 -0700
Message-ID: <4A89C026.4030402@us.ibm.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:44716 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767AbZHQUkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 16:40:21 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7HKca8v020421
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 14:38:36 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7HKe8T2125814
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 14:40:09 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7HKe7ZH003534
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 14:40:08 -0600
In-Reply-To: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:
> If I use a large send queue
> 
> (echo 2000000 >/proc/sys/net/core/wmem_default)
> 
> then lots of packet loss results if I try to send more packets than
> the bandwidth of the wire (300 bytes the maximum rate is 341k pps). With a
> size of 2M for the output buffer the TX ring is overrun.
> 
> But this loss is nowhere seen in any counter increments:

Is there any chance this is getting dropped at qdisc?
Can you check with tc?

thanks,
Nivedita
