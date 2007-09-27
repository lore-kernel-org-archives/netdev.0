From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] net: Make the loopback device per network namespace
Date: Wed, 26 Sep 2007 22:11:11 -0700 (PDT)
Message-ID: <20070926.221111.67579385.davem@davemloft.net>
References: <m1ir5xrngu.fsf@ebiederm.dsl.xmission.com>
	<m1bqbprnc2.fsf_-_@ebiederm.dsl.xmission.com>
	<m17imdrn8r.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50075
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752493AbXI0FLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 01:11:11 -0400
In-Reply-To: <m17imdrn8r.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 26 Sep 2007 18:00:20 -0600

> 
> This patch makes loopback_dev per network namespace.  Adding
> code to create a different loopback device for each network
> namespace and adding the code to free a loopback device
> when a network namespace exits.
> 
> This patch modifies all users the loopback_dev so they
> access it as init_net.loopback_dev, keeping all of the
> code compiling and working.  A later pass will be needed to
> update the users to use something other than the initial network
> namespace.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24, thanks Eric.
