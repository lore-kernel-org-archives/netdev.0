From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/2] dmaengine: preparation for raid acceleration
Date: Wed, 27 Jun 2007 00:54:16 -0700 (PDT)
Message-ID: <20070627.005416.43852201.davem@davemloft.net>
References: <20070602001527.1707.58092.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	christopher.leech@intel.com
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33293
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753549AbXF0Hx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 03:53:57 -0400
In-Reply-To: <20070602001527.1707.58092.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 01 Jun 2007 17:17:49 -0700

> Hello David,
> 
> The following two patches are part of the raid acceleration series I
> would like to push for 2.6.23 consideration.  I am sending these two
> separately for your review for the following reasons: the 'dmaengine'
> core initially came in through netdev,  patch #2 makes changes to
> net/dev/core.c, and lastly I have an ack on the raid changes but no ack
> from the community on the i/oat and dmaengine changes.
> 
>       dmaengine: add base support for the async_tx api
>       dmaengine: move channel management to the client

Dan, you can merge this through Andrew's -mm tree and this
will actually make things easier for me.  The net changes
are minimal and I have no problem with them.

Acked-by: David S. Miller <davem@davemloft.net>
