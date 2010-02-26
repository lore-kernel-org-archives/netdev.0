From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH] ethtool: Add n-tuple string length to
 drvinfo and return it
Date: Fri, 26 Feb 2010 12:08:32 -0800
Message-ID: <1267214912.2224.1.camel@localhost>
References: <20100226115355.20213.59254.stgit@localhost.localdomain>
	 <20100226.042027.250812962.davem@davemloft.net>
	 <4B87C70F.8060403@garzik.org>
	 <20100226.051145.01410157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30005 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965910Ab0BZUIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 15:08:34 -0500
In-Reply-To: <20100226.051145.01410157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-26 at 05:11 -0800, David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Fri, 26 Feb 2010 08:05:19 -0500
> 
> > NAK.  Did you even read the patch?
> 
> I did, brain doesn't work sometimes :-)
> 
> > We don't increase the size of struct ethtool_drvinfo, _especially_ by
> > sticking struct members into the middle of the struct.
> > 

Brain lapse.  When you mentioned ABI not being locked down until 2.6.34
is dropped, I didn't think.

I'm testing your proposed change, and once I have it working, I'll give
it to Jeff K. to get pushed along with a new userspace patch.

> > What do you think 'reserved' is for???
> 
> Right, I'll revert, thanks.


