From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/16] net: netlink support for moving devices between
 network namespaces.
Date: Wed, 12 Sep 2007 04:57:40 -0700 (PDT)
Message-ID: <20070912.045740.71104218.davem@davemloft.net>
References: <m13axovnyf.fsf_-_@ebiederm.dsl.xmission.com>
	<m1y7fgu9ax.fsf_-_@ebiederm.dsl.xmission.com>
	<m1tzq4u92n.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:38220
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764975AbXILL6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 07:58:11 -0400
In-Reply-To: <m1tzq4u92n.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:43:44 -0600

> 
> The simplest thing to implement is moving network devices between
> namespaces.  However with the same attribute IFLA_NET_NS_PID we can
> easily implement creating devices in the destination network
> namespace as well.  However that is a little bit trickier so this
> patch sticks to what is simple and easy.
> 
> A pid is used to identify a process that happens to be a member
> of the network namespace we want to move the network device to.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24, thanks.
