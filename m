From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: bookkeep number of queues in our own
 module
Date: Mon, 23 Jun 2014 02:08:42 -0700 (PDT)
Message-ID: <20140623.020842.1000912698437075036.davem@davemloft.net>
References: <20140622.001355.624567316306796984.davem@davemloft.net>
	<20140622111657.GA7528@zion.uk.xensource.com>
	<9AAE0902D5BC7E449B7C8E4E778ABCD03BBD51@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, boris.ostrovsky@oracle.com,
	Ian.Campbell@citrix.com
To: Paul.Durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53717 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753740AbaFWJIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:08:45 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD03BBD51@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <Paul.Durrant@citrix.com>
Date: Mon, 23 Jun 2014 07:59:16 +0000

> Bear in mind that the original intention of the multi-queue patches
> was to allow the queue selection algorithm to be negotiated with the
> frontend (see
> http://lists.xen.org/archives/html/xen-devel/2013-06/msg02654.html). Particularly,
> if the frontend is Windows then netback will need to use a Toeplitz
> hash to steer traffic since this is stipulated by Microsoft's RSS
> (Receive Side Scaling) interfaces. So, IMO netback should always
> implement a select queue method, otherwise any (theoretical)
> algorithm change in __netdev_pick_tx() would be immediately imposed
> on frontends, possibly causing them to misbehave.

I do not think you are obligated to use Toeplitz or whatever scheme
the other side wants, especially if the user on the xen-netback side
asked for XPS or similar to be used.
