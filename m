From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-2.6 PATCH 1/3] ixgbe: Fix compiler warning about variable
 being used uninitialized
Date: Sun, 13 Dec 2009 20:55:22 -0800
Message-ID: <1260766522.20884.0.camel@localhost>
References: <20091212075120.10952.98484.stgit@localhost.localdomain>
	 <20091213.192029.104053340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46223 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756141AbZLNEzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 23:55:23 -0500
In-Reply-To: <20091213.192029.104053340.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-12-13 at 19:20 -0800, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 11 Dec 2009 23:51:23 -0800
> 
> > From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> > 
> > tc is still throwing a warning that is could be used
> > uninitialized.  This fixes it.
> > 
> > Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> It's warning because it absolutely can be used uninitialized.
> 
> The two code blocks only handle two chip variants.  Why not
> make what's happening here explicit by using a switch
> statement and having a 'default' case?

That I can do, and makes more sense.  I'll respin the patch.

Thanks Dave,
-PJ

