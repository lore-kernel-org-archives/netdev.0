From: James Chapman <jchapman@katalix.com>
Subject: Re: [RFC 3/4] net: pppol2tp - introduce net-namespace functionality
Date: Sat, 10 Jan 2009 13:13:43 +0000
Message-ID: <49689F07.3000401@katalix.com>
References: <20090109195154.320495476@gmail.com>> <4967accc.0c58560a.2ee6.3de4@mx.google.com> <49688120.9000507@katalix.com> <20090110111359.GA29349@localhost> <20090110125444.GB29349@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:47960 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441AbZAJNNw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2009 08:13:52 -0500
In-Reply-To: <20090110125444.GB29349@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cyrill Gorcunov wrote:
> [Cyrill Gorcunov - Sat, Jan 10, 2009 at 02:13:59PM +0300]
> | [James Chapman - Sat, Jan 10, 2009 at 11:06:08AM +0000]
> | | Cyrill Gorcunov wrote:
> | | > - Each tunnel and appropriate lock are inside own namespace now.
> | | > - pppox code allows to create per-namespace sockets for
> | | >   both PX_PROTO_OE and PX_PROTO_OL2TP protocols. Actually since
> | | >   now pppox_create support net-namespaces new PPPo... protocols
> | | >   (if they ever will be) should support net-namespace too otherwise
> | | >   explicit check for &init_net would be needed.
> | | > 
> | | > CC: James Chapman <jchapman@katalix.com>
> | | > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> | | > ---
> | | >  drivers/net/pppol2tp.c |  164 ++++++++++++++++++++++++++++++++++++-------------
> | | >  drivers/net/pppox.c    |    4 -
> | | >  2 files changed, 121 insertions(+), 47 deletions(-)
> | | 
> | | Looks ok from a pppol2tp point of view, though I'm not an expert on the
> | | netns stuff.
> | | 
> | | The patches don't apply against latest net-next-2.6. If you respin the
> | | patches, I'll test them for pppol2tp.
> | | 
> | | -- 
> | | James Chapman
> | | Katalix Systems Ltd
> | | http://www.katalix.com
> | | Catalysts for your Embedded Linux software development
> | | 
> | 
> | Thanks James for taken look on. I'll check the latest net-next-2.6
> | tree and update the patches soon. Thanks!
> | 
> | 		- Cyrill -
> 
> James I just fetched latest net-next-2.6 with
> commit
> 
> ---
> commit 3c92ec8ae91ecf59d88c798301833d7cf83f2179
> Merge: c4c9f01... ca9153a...
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Sun Dec 28 16:54:33 2008 -0800
> 
>     Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/git/paulus/powerpc
> ---
> 
> and patches are being applied on top without problems.
> Maybe you have some other commits which are not propogated
> to net-next-2.6 yet?

My mistake. I missed one of the patches when applying the series.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

