From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] add dev_to_node()
Date: Sun, 05 Nov 2006 00:22:37 -0800 (PST)
Message-ID: <20061105.002237.18309940.davem@davemloft.net>
References: <20061104225629.GA31437@lst.de>
	<20061104230648.GB640@redhat.com>
	<20061104235323.GA1353@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7122
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965854AbWKEIWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 03:22:31 -0500
To: hch@lst.de
In-Reply-To: <20061104235323.GA1353@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Sun, 5 Nov 2006 00:53:23 +0100

> On Sat, Nov 04, 2006 at 06:06:48PM -0500, Dave Jones wrote:
> > On Sat, Nov 04, 2006 at 11:56:29PM +0100, Christoph Hellwig wrote:
> > 
> > This will break the compile for !NUMA if someone ends up doing a bisect
> > and lands here as a bisect point.
> > 
> > You introduce this nice wrapper..
> 
> The dev_to_node wrapper is not enough as we can't assign to (-1) for
> the non-NUMA case.  So I added a second macro, set_dev_node for that.
> 
> The patch below compiles and works on numa and non-NUMA platforms.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks good to me.
