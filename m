From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] netns: Remove net_alive
Date: Sun, 22 Feb 2009 00:11:17 -0800 (PST)
Message-ID: <20090222.001117.21723003.davem@davemloft.net>
References: <m1bpsxhzqz.fsf@fess.ebiederm.org>
	<m163j5hzow.fsf_-_@fess.ebiederm.org>
	<m1zlghgkpa.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	adobriyan@gmail.com, den@openvz.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59818
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752454AbZBVILf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 03:11:35 -0500
In-Reply-To: <m1zlghgkpa.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 20 Feb 2009 08:02:57 -0800

> 
> It turns out that net_alive is unnecessary, and the original problem
> that led to it being added was simply that the icmp code thought
> it was a network device and wound up being unable to handle packets
> while there were still packets in the network namespace.
> 
> Now that icmp and tcp have been fixed to properly register themselves
> this problem is no longer present and we have a stronger guarantee
> that packets will not arrive in a network namespace then that provided
> by net_alive in netif_receive_skb.  So remove net_alive allowing
> packet reception run a little faster.
> 
> Additionally document the strong reason why network namespace cleanup
> is safe so that if something happens again someone else will have
> a chance of figuring it out.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>

Also applied, thanks Eric.
