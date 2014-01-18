From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH v2 net] bpf: do not use reciprocal divide
Date: Sat, 18 Jan 2014 11:12:30 +0100
Message-ID: <20140118101230.GA3462@osiris>
References: <1389797407.31367.340.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140115.170230.640619926492650356.davem@davemloft.net>
 <20140117085916.GA4208@osiris>
 <20140117.185600.1405505573912550580.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, schwidefsky@de.ibm.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	dborkman@redhat.com, darkjames-ws@darkjames.pl, mgherzan@gmail.com,
	rmk+kernel@arm.linux.org.uk, matt@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:60260 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363AbaARKMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 05:12:38 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <heiko.carstens@de.ibm.com>;
	Sat, 18 Jan 2014 10:12:36 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 08B511B08061
	for <netdev@vger.kernel.org>; Sat, 18 Jan 2014 10:11:56 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0IACKDV64880728
	for <netdev@vger.kernel.org>; Sat, 18 Jan 2014 10:12:20 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0IACVHS003704
	for <netdev@vger.kernel.org>; Sat, 18 Jan 2014 03:12:32 -0700
Content-Disposition: inline
In-Reply-To: <20140117.185600.1405505573912550580.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 06:56:00PM -0800, David Miller wrote:
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> Date: Fri, 17 Jan 2014 09:59:16 +0100
> 
> > Could you please also apply the patch below to your tree? It would only
> > generate a merge conflict, that would need fixing, if it would sit in the
> > s390 tree.
> 
> Applied and I queued it up for -stable so I can combine it with
> Eric's original change when I submit it to -stable.

Great, thank you!
