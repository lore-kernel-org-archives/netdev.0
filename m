From: Christoph Lameter <cl@linux.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Fri, 17 Apr 2009 09:46:11 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904170943300.11877@qirst.com>
References: <alpine.DEB.1.10.0904161504090.15835@qirst.com> <49E786FE.6090304@cosmosbay.com> <alpine.DEB.1.10.0904161532350.22449@qirst.com> <20090416.154701.21872281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dada1@cosmosbay.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:57651 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932118AbZDQNx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 09:53:29 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3BD0782C386
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 10:03:28 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id kKUueXDrXGY9 for <netdev@vger.kernel.org>;
	Fri, 17 Apr 2009 10:03:28 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D15F982C388
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 10:03:21 -0400 (EDT)
In-Reply-To: <20090416.154701.21872281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, David Miller wrote:

> More seriously, it's going to be hard to isolate anything
> unless you concern yourself with changes to one thing
> on one system at a time.

Only the kernel version was changed on both systems. Changing only a
single system would have meant considering complex interactions between
the network layers of varying versions which would make
the problem even more difficult to track down.

I changed one thing: The kernel version.
