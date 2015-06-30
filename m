From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: mlx4: "failed to allocate default counter port 1"
Date: Tue, 30 Jun 2015 15:24:58 +0200 (CEST)
Message-ID: <alpine.LFD.2.11.1506301520180.1799@denkbrett>
References: <alpine.LFD.2.11.1506301229520.1799@denkbrett> <5592913C.3000207@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eran Ben Elisha <eranbe@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Hadar Hen Zion <hadarh@mellanox.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:43993 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbbF3NZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 09:25:04 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sebott@linux.vnet.ibm.com>;
	Tue, 30 Jun 2015 14:25:02 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id C1BA917D8059
	for <netdev@vger.kernel.org>; Tue, 30 Jun 2015 14:26:11 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5UDP0A635979376
	for <netdev@vger.kernel.org>; Tue, 30 Jun 2015 13:25:00 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5UDOxoL022827
	for <netdev@vger.kernel.org>; Tue, 30 Jun 2015 07:24:59 -0600
In-Reply-To: <5592913C.3000207@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Jun 2015, Or Gerlitz wrote:
> On 6/30/2015 1:45 PM, Sebastian Ott wrote:
> > [   88.909558] mlx4_slave_cmd op=3840, ret=-22, status=3
> > [   88.909562] mlx4_core 0000:00:00.0: mlx4_allocate_default_counters:
> > failed to allocate default counter port 1 err -22
> > [   88.909564] mlx4_core 0000:00:00.0: Failed to allocate default counters,
> > aborting
> > [   88.961735] mlx4_core: probe of 0000:00:00.0 failed with error -22
> 
> Do you run the VF on the same system/kernel as the PF, or the VF is probed to
> VM which runs the latest kernel and the PF runsolder kernel (which?)

The latter case. The PF is driven by a much older Kernel running OFED
2.3.2.0.0.1

> Can you also hook the PF code that serves this flow to see where we actually
> fail? basically, we should be going this way mlx4_ALLOC_RES_wrapper -->
> counter_alloc_res -- so I'd like to see which of the branches in
> counter_alloc_res fails...

Nope, I don't have direct access to the PF, sry.

Sebastian
> 
> Or.
> 
> 
> 
> 
