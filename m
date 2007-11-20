From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 3/6] net: Make the netlink methods in rtnetlink
 handle multiple network namespaces
Date: Mon, 19 Nov 2007 22:33:47 -0800 (PST)
Message-ID: <20071119.223347.64509613.davem@davemloft.net>
References: <20071115155836.GA25458@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, dlezcano@fr.ibm.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35010
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753146AbXKTGds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:33:48 -0500
In-Reply-To: <20071115155836.GA25458@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 15 Nov 2007 18:58:36 +0300

> From: Eric W. Biederman <ebiederm@xmission.com>
> 
> After the previous prep work this just consists of removing checks
> limiting the code to work in the initial network namespace, and
> updating rtmsg_ifinfo so we can generate events for devices in
> something other then the initial network namespace.
> 
> Referring to network other network devices like the IFLA_LINK
> and IFLA_MASTER attributes do, gets interesting if those network
> devices happen to be in other network namespaces.  Currently
> ifindex numbers are allocated globally so I have taken the path
> of least resistance and not still report the information even
> though the devices they are talking about are invisible.
> 
> If applications start getting confused or when ifindex
> numbers become local to the network namespace we may need
> to do something different in the future.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Denis V. Lunev <den@openz.org>

Applied, thanks.
