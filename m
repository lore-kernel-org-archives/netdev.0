From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 3/4] net: pppol2tp - introduce net-namespace functionality
Date: Sat, 10 Jan 2009 14:13:59 +0300
Message-ID: <20090110111359.GA29349@localhost>
References: <20090109195154.320495476@gmail.com>> <4967accc.0c58560a.2ee6.3de4@mx.google.com> <49688120.9000507@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:39600 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbZAJLOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 06:14:04 -0500
Content-Disposition: inline
In-Reply-To: <49688120.9000507@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[James Chapman - Sat, Jan 10, 2009 at 11:06:08AM +0000]
| Cyrill Gorcunov wrote:
| > - Each tunnel and appropriate lock are inside own namespace now.
| > - pppox code allows to create per-namespace sockets for
| >   both PX_PROTO_OE and PX_PROTO_OL2TP protocols. Actually since
| >   now pppox_create support net-namespaces new PPPo... protocols
| >   (if they ever will be) should support net-namespace too otherwise
| >   explicit check for &init_net would be needed.
| > 
| > CC: James Chapman <jchapman@katalix.com>
| > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
| > ---
| >  drivers/net/pppol2tp.c |  164 ++++++++++++++++++++++++++++++++++++-------------
| >  drivers/net/pppox.c    |    4 -
| >  2 files changed, 121 insertions(+), 47 deletions(-)
| 
| Looks ok from a pppol2tp point of view, though I'm not an expert on the
| netns stuff.
| 
| The patches don't apply against latest net-next-2.6. If you respin the
| patches, I'll test them for pppol2tp.
| 
| -- 
| James Chapman
| Katalix Systems Ltd
| http://www.katalix.com
| Catalysts for your Embedded Linux software development
| 

Thanks James for taken look on. I'll check the latest net-next-2.6
tree and update the patches soon. Thanks!

		- Cyrill -
