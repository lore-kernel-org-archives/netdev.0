From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/6] e1000e: remove namespace collisions with e1000
Date: Tue, 14 Aug 2007 01:13:26 -0400
Message-ID: <46C139F6.2040007@garzik.org>
References: <20070810200038.21509.77815.stgit@localhost.localdomain> <20070810200047.21509.46779.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andi@firstfloor.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50060 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936385AbXHNFN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:13:28 -0400
In-Reply-To: <20070810200047.21509.46779.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> To prevent future collisions we rename all extern's from e1000_
> to e1000e_*. The list of changed symbols was taken from e1000.h
> Compile tested with CONFIG_E1000=y and CONFIG_E1000E=y.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/82571.c   |  129 +++++++++++++-------------
>  drivers/net/e1000e/e1000.h   |  194 +++++++++++++++++++--------------------
>  drivers/net/e1000e/es2lan.c  |  118 ++++++++++++------------
>  drivers/net/e1000e/ethtool.c |   62 ++++++------
>  drivers/net/e1000e/ich8lan.c |   92 +++++++++---------
>  drivers/net/e1000e/lib.c     |  210 +++++++++++++++++++++---------------------
>  drivers/net/e1000e/netdev.c  |  168 +++++++++++++++++-----------------
>  drivers/net/e1000e/param.c   |    8 +-
>  drivers/net/e1000e/phy.c     |  138 ++++++++++++++--------------
>  9 files changed, 559 insertions(+), 560 deletions(-)

if you grep around this effort was already started using the 'e1e_' 
prefix.  I like the shorter prefix, but your call ultimately.  Either 
way, make sure to make the driver consistent there too.

e1e_flush(), e1e_wphy(), etc.

Overall I still want to push the driver towards shorter function and 
variable names.  Things like
e1000e_get_speed_and_duplex_fiber_serdes are just way too long.

	Jeff


