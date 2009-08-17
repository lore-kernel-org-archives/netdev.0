From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Mon, 17 Aug 2009 15:43:54 -0700
Message-ID: <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>
	 <4A89C026.4030402@us.ibm.com>
	 <alpine.DEB.1.10.0908171642500.20399@gentwo.org>
	 <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>
	 <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:58082 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbZHQWn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 18:43:58 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7HMh3WX005084
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 16:43:03 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7HMhtpw205198
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 16:43:55 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7HMhtbT030228
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2009 16:43:55 -0600
In-Reply-To: <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-08-17 at 18:13 -0400, Christoph Lameter wrote:
> On Mon, 17 Aug 2009, Sridhar Samudrala wrote:
> 
> > What about ethtool -S ? Does it report any errors?
> 
> Neither. This is is a broadcom bnx2 NIC.

Are you sure the packets are dropped at the sender?
Another place where packet drops/errors are counted is
    /proc/net/softnet_stat
It tracks some counters that could result in drops. I thought these are
all receive statistics. But looks like cpu_collision is a tx stat. The
name of the structure is netif_rx_stat and it includes cpu_collison 
counter.

Thanks
Sridhar

