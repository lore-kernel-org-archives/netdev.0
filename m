From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] sfc: Clear I2C adapter structure in
 falcon_remove_nic()
Date: Wed, 04 Mar 2009 17:55:32 -0800 (PST)
Message-ID: <20090304.175532.257753740.davem@davemloft.net>
References: <1236196272.3140.15.camel@achroite>
	<1236196382.3140.21.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37449
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753561AbZCEBzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 20:55:47 -0500
In-Reply-To: <1236196382.3140.21.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 04 Mar 2009 19:53:02 +0000

> i2c_del_adapter() leaves dangling pointers in the structure.  If we
> retry the NIC probe and pass the structure to i2c_add_adapter() again
> it will lead to an oops unless we clear it first.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
