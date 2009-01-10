From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 3/4] net: pppol2tp - introduce net-namespace functionality
Date: Sat, 10 Jan 2009 15:54:44 +0300
Message-ID: <20090110125444.GB29349@localhost>
References: <20090109195154.320495476@gmail.com>> <4967accc.0c58560a.2ee6.3de4@mx.google.com> <49688120.9000507@katalix.com> <20090110111359.GA29349@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: James Chapman <jchapman@katalix.com>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org, xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:60902 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709AbZAJMyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 07:54:49 -0500
Content-Disposition: inline
In-Reply-To: <20090110111359.GA29349@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Cyrill Gorcunov - Sat, Jan 10, 2009 at 02:13:59PM +0300]
| [James Chapman - Sat, Jan 10, 2009 at 11:06:08AM +0000]
| | Cyrill Gorcunov wrote:
| | > - Each tunnel and appropriate lock are inside own namespace now.
| | > - pppox code allows to create per-namespace sockets for
| | >   both PX_PROTO_OE and PX_PROTO_OL2TP protocols. Actually since
| | >   now pppox_create support net-namespaces new PPPo... protocols
| | >   (if they ever will be) should support net-namespace too otherwise
| | >   explicit check for &init_net would be needed.
| | > 
| | > CC: James Chapman <jchapman@katalix.com>
| | > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
| | > ---
| | >  drivers/net/pppol2tp.c |  164 ++++++++++++++++++++++++++++++++++++-------------
| | >  drivers/net/pppox.c    |    4 -
| | >  2 files changed, 121 insertions(+), 47 deletions(-)
| | 
| | Looks ok from a pppol2tp point of view, though I'm not an expert on the
| | netns stuff.
| | 
| | The patches don't apply against latest net-next-2.6. If you respin the
| | patches, I'll test them for pppol2tp.
| | 
| | -- 
| | James Chapman
| | Katalix Systems Ltd
| | http://www.katalix.com
| | Catalysts for your Embedded Linux software development
| | 
| 
| Thanks James for taken look on. I'll check the latest net-next-2.6
| tree and update the patches soon. Thanks!
| 
| 		- Cyrill -

James I just fetched latest net-next-2.6 with
commit

---
commit 3c92ec8ae91ecf59d88c798301833d7cf83f2179
Merge: c4c9f01... ca9153a...
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Sun Dec 28 16:54:33 2008 -0800

    Merge branch 'next' of git://git.kernel.org/pub/scm/linux/kernel/git/paulus/powerpc
---

and patches are being applied on top without problems.
Maybe you have some other commits which are not propogated
to net-next-2.6 yet?

		- Cyrill -
