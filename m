From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 5/5] bonding: Allow setting max_bonds to zero
Date: Tue, 17 Jun 2008 23:31:16 -0400
Message-ID: <48588184.5030808@pobox.com>
References: <12134059242107-git-send-email-fubar@us.ibm.com> <12134059253135-git-send-email-fubar@us.ibm.com> <12134059253839-git-send-email-fubar@us.ibm.com> <12134059261873-git-send-email-fubar@us.ibm.com> <12134059261828-git-send-email-fubar@us.ibm.com> <12134059271179-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Phil Oester <kernel@linuxace.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41832 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757615AbYFRDbU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 23:31:20 -0400
In-Reply-To: <12134059271179-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> 	Permit bonding to function rationally if max_bonds is set to
> zero.  This will load the module, but create no master devices (which can
> be created via sysfs).
> 
> 	Requires some change to bond_create_sysfs; currently, the
> netdev sysfs directory is determined from the first bonding device created,
> but this is no longer possible.  Instead, an interface from net/core is
> created to create and destroy files in net_class.
> 
> 	Based on a patch submitted by Phil Oester <kernel@linuxaces.com>.
> Modified by Jay Vosburgh to fix the sysfs issue mentioned above and to
> update the documentation.
> 
> Signed-off-by: Phil Oester <kernel@linuxace.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

applied 1-5


