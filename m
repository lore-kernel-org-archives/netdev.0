From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] C/R: Add checkpoint support to macvlan driver
Date: Fri, 26 Feb 2010 04:09:52 -0800 (PST)
Message-ID: <20100226.040952.67809551.davem@davemloft.net>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
	<1267130595-23637-7-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, benjamin.thery@bull.net, den@openvz.org,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: danms@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38705
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935157Ab0BZMJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:09:34 -0500
In-Reply-To: <1267130595-23637-7-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>
Date: Thu, 25 Feb 2010 12:43:15 -0800

> This has an small hidden gotcha.  Since the macvlan device is moved
> completely into a container's network namespace, the init netns cannot
> freeze traffic to and from it in order to migrate live network connections
> by simply utilizing its netfilter tables.  A helper process in the container
> or something like what was recently discussed on the containers list[1]
> would provide a way to do this.
> 
> [1]: https://lists.linux-foundation.org/pipermail/containers/2010-February/023001.html
> 
> Signed-off-by: Dan Smith <danms@us.ibm.com>

Acked-by: David S. Miller <davem@davemloft.net>
