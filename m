From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] netns: add /proc/*/net/id symlink
Date: Mon, 23 May 2011 03:47:51 +0200
Message-ID: <20110523014751.GB2351982@jupiter.n2.diac24.net>
References: <20110521093936.GA3015@p183>
 <m11uzsxdty.fsf@fess.ebiederm.org>
 <20110521223054.GA3198@p183>
 <m1vcx3r3o5.fsf@fess.ebiederm.org>
 <20110523014303.GA2351982@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:44889 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752957Ab1EWBsB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 21:48:01 -0400
Content-Disposition: inline
In-Reply-To: <20110523014303.GA2351982@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 23, 2011 at 03:43:03AM +0200, David Lamparter wrote:
> Then I make a mount namespace, bind-mount the net namespace, bind mount
> the mount namespace and terminate all processes that reference it (yes
> this does work, i just checked [!]).

Actually, Eric, bind-mounting a mount namespace inside itself should
probably be forbidden? No idea if you changed that (running a year-old
version of your patches here). Not only can you lose network namespaces
inside those self-referential mount namespaces but also references to
block devices, unix socket connections, etc. pp.


-David

