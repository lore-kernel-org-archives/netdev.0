From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Mon, 17 Aug 2009 14:50:39 -0700
Message-ID: <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>
	 <4A89C026.4030402@us.ibm.com>
	 <alpine.DEB.1.10.0908171642500.20399@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:60818 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbZHQVul (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2009 17:50:41 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7HLoRsj028336
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 17:50:27 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7HLogJ5222088
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 17:50:42 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7HLofQe025318
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 17:50:42 -0400
In-Reply-To: <alpine.DEB.1.10.0908171642500.20399@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-08-17 at 16:46 -0400, Christoph Lameter wrote:
> On Mon, 17 Aug 2009, Nivedita Singhvi wrote:
> 
> > Is there any chance this is getting dropped at qdisc?
> > Can you check with tc?
> 
> I checked and the counter there is zero.
> 
> :/home/clameter# tc -s qdisc show
> 
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1
> 1 1 1 1 1
>  Sent 3042712708 bytes 8896862 pkt (dropped 0, overlimits 0 requeues 56303)
>  rate 0bit 0pps backlog 0b 0p requeues 56303

What about ethtool -S ? Does it report any errors?

Thanks
Sridhar

