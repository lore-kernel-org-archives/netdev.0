From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [RFC] Add sock_create_kern_net()
Date: Tue, 27 Apr 2010 17:18:44 -0700 (PDT)
Message-ID: <20100427.171844.77354120.davem@davemloft.net>
References: <1272034539-19899-1-git-send-email-danms@us.ibm.com>
	<1272034539-19899-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: danms@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39582
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755658Ab0D1ASi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 20:18:38 -0400
In-Reply-To: <1272034539-19899-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>
Date: Fri, 23 Apr 2010 07:55:37 -0700

> This helper allows kernel routines to create a socket in a given netns,
> instead of forcing it to the initial or current one.
> 
> I know this seems like it's violating the netns boundary.  The intended
> use (as in the following patches) is specifically when talking to RTNETLINK
> in another netns for the purposes of creating or examining resources there.
> It is expected that this will be used for that sort of transient socket
> creation only.  In other words:

If you can create netlink sockets in a remote NS you can also make
changes there, and the whole point is to disallow changes.

So maybe you won't be making changes, but others will think about
using this and doing so.

At a high level, I think this is a really bad idea, so I won't be
applying this, sorry.
