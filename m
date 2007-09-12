From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/16] net: Initialize the network namespace of network
 devices.
Date: Wed, 12 Sep 2007 03:58:19 -0700 (PDT)
Message-ID: <20070912.035819.23024601.davem@davemloft.net>
References: <m11wd8x3a3.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl5ovolm.fsf_-_@ebiederm.dsl.xmission.com>
	<m1odgcvoje.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:35393
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965891AbXILK6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:58:22 -0400
In-Reply-To: <m1odgcvoje.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:24:21 -0600

> 
> Except for carefully selected pseudo devices all network
> interfaces should start out in the initial network namespace.
> Ultimately it will be register_netdev that examines what
> dev->nd_net is set to and places a device in a network namespace.
> 
> This patch modifies alloc_netdev to initialize the network
> namespace a device is in with the initial network namespace.
> This gets it right for the vast majority of devices so their
> drivers need not be modified and for those few pseudo devices
> that need something different they can change this parameter
> before calling register_netdevice.
> 
> The network namespace parameter on a network device is not
> reference counted as the devices are inside of a network namespace
> and cannot remain in that namespace past the lifetime of the
> network namespace.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24, thanks.
