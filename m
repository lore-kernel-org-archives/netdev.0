From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: Allow setting the L3 MTU
Date: Tue, 03 Mar 2009 23:36:16 -0800 (PST)
Message-ID: <20090303.233616.17571375.davem@davemloft.net>
References: <m1ab813ox1.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	dlezcano@fr.ibm.com, xemul@openvz.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33403
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751808AbZCDHgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 02:36:31 -0500
In-Reply-To: <m1ab813ox1.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 03 Mar 2009 20:14:18 -0800

> The limitation to only 1500 byte mtu's limits the utility of the veth
> device for testing routing.  So implement implement a configurable
> MTU.
> 
> For consistency I drop packets on the receive side when they are
> larger than the MTU.  I count those drops.  And I allow
> a little padding for vlan headers.
> 
> I also test the mtu when a new device is created with netlink
> because that path currently bypasses the current mtu setting
> code.
> 
> Signed-off-by: Eric Biederman <ebiederm@aristanetworks.com>

Applied to net-next-2.6, thanks Eric.
