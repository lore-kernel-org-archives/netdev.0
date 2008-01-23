From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/12 net-2.6.25] [NETNS]: Routing namespacing on IP
 output path.
Date: Tue, 22 Jan 2008 22:09:52 -0800 (PST)
Message-ID: <20080122.220952.251770012.davem@davemloft.net>
References: <479612BE.8030409@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36089
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753215AbYAWGJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 01:09:44 -0500
In-Reply-To: <479612BE.8030409@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Tue, 22 Jan 2008 18:58:54 +0300

> This set introduces namespacing in the IP output path. The namespace is
> added to all routing API functions except ones with a valid socket. This
> is very intrusive.
> 
> Routing cache is virtualized as a part of this efforts, though the hash
> function is not tuned to use namespace id. This not required to work in
> initial namespace.
> 
> ICMP replies now also use correct namespace.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Only patches to 1-9 (out of 12) showed up in my mailbox and the netdev
list so that is what I applied :-)

Thanks!
