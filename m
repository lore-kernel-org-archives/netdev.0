From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: bookkeep number of queues in our own
 module
Date: Mon, 23 Jun 2014 02:25:32 -0700 (PDT)
Message-ID: <20140623.022532.105159906302303437.davem@davemloft.net>
References: <9AAE0902D5BC7E449B7C8E4E778ABCD03BBD51@AMSPEX01CL01.citrite.net>
	<20140623084831.GV20819@zion.uk.xensource.com>
	<9AAE0902D5BC7E449B7C8E4E778ABCD03BC2F7@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, boris.ostrovsky@oracle.com,
	Ian.Campbell@citrix.com
To: Paul.Durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbaFWJZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:25:33 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD03BC2F7@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <Paul.Durrant@citrix.com>
Date: Mon, 23 Jun 2014 09:18:23 +0000

> Ok, for the addition of a new algorithm that may be the case but
> what about the existent algorithm stability issue? Who's going to
> watch the implementation of __netdev_pick_tx() and make sure there
> is no semantic change? I'm still of the opinion that the
> implementation should be kept within netback so that we can
> guarantee stability, even if it means duplication. Either that or we
> need some guarantee that the semantic of __netdev_pick_tx() will
> never change.

Please stop talking like this.

If the default changes it's probably to fix a bug or make things
better, you want no bugs to get fix if it breaks "stability"?
