From: James Morris <jmorris@namei.org>
Subject: Re: [DOC]: generic netlink
Date: Mon, 19 Jun 2006 11:13:18 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606191057420.21114@d.namei>
References: <1150724482.5815.48.camel@jzny2>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Jay Lan <jlan@engr.sgi.com>,
	Shailabh Nagar <nagar@watson.ibm.com>,
	Per Liden <per.liden@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:52437 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750884AbWFSPNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 11:13:21 -0400
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1150724482.5815.48.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Jun 2006, jamal wrote:

> Attached is a document that should help people wishing to use generic
> netlink interface. It is a WIP so a lot more to go if i see interest.

Thanks for writing this up.

It seems that TIPC is multiplexing all of it's commands through  
TIPC_GENL_CMD.

I wonder, if this is how other protocols are likely to utilize genl, then 
we could possibly drop the command registration code completely and one 
command op can be registered by the protocol during 
genl_register_family().

This would both simplify the genl code and API, and help ensure 
consistency of users.



- James
-- 
James Morris
<jmorris@namei.org>
