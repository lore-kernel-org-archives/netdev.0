From: Jan Glauber <jang@linux.vnet.ibm.com>
Subject: Re: [PATCH] 3com: make 3c59x depend on HAS_IOPORT
Date: Wed, 05 Dec 2012 20:44:26 +0100
Message-ID: <1354736666.14042.7.camel@localhost.localdomain>
References: <1354716280.29038.2.camel@hal>
	 <20121205.125804.979819753893520607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:52613 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428Ab2LETru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 14:47:50 -0500
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <jang@linux.vnet.ibm.com>;
	Wed, 5 Dec 2012 19:47:41 -0000
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB5JlbXa58654720
	for <netdev@vger.kernel.org>; Wed, 5 Dec 2012 19:47:37 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB5JliTH013787
	for <netdev@vger.kernel.org>; Wed, 5 Dec 2012 12:47:45 -0700
In-Reply-To: <20121205.125804.979819753893520607.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-05 at 12:58 -0500, David Miller wrote:
> From: Jan Glauber <jang@linux.vnet.ibm.com>
> Date: Wed, 05 Dec 2012 15:04:40 +0100
> 
> > From: Jan Glauber <jang@linux.vnet.ibm.com>
> > 
> > The 3com driver for 3c59x requires ioport_map. Since not all
> > architectures support IO port mapping make 3c59x dependent on HAS_IOPORT.
> > 
> > Signed-off-by: Jan Glauber <jang@linux.vnet.ibm.com>
> 
> Which platforms support PCI or EISA yet do not set HAS_IOPORT?
> 

s390. We wont get support for port I/O in the PCI hardware/firmware
layer. (The patches for PCI on s390 are currently in linux-next).

--Jan
