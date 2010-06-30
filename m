From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/3] ethtool: Change ethtool_op_set_flags
 to validate flags
Date: Wed, 30 Jun 2010 14:10:27 -0700 (PDT)
Message-ID: <20100630.141027.219740852.davem@davemloft.net>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	sgruszka@redhat.com, amit.salecha@qlogic.com, amwang@redhat.com,
	anirban.chakraborty@qlogic.com, dm@chelsio.com, scofeldm@cisco.com,
	vkolluri@cisco.com, roprabhu@cisco.com,
	e1000-devel@lists.sourceforge.net, buytenh@wantstofly.org,
	gallatin@myri.com, brice@myri.com, shemminger@linux-foundation.org,
	jgarzik@redhat.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57472
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752944Ab0F3VKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 17:10:14 -0400
In-Reply-To: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 30 Jun 2010 13:44:32 +0100

> ethtool_op_set_flags() does not check for unsupported flags, and has
> no way of doing so.  This means it is not suitable for use as a
> default implementation of ethtool_ops::set_flags.
> 
> Add a 'supported' parameter specifying the flags that the driver and
> hardware support, validate the requested flags against this, and
> change all current callers to pass this parameter.
> 
> Change some other trivial implementations of ethtool_ops::set_flags to
> call ethtool_op_set_flags().
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>
> Acked-by: Jeff Garzik <jgarzik@redhat.com>

Applied.
