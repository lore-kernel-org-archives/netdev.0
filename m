From: David Lamparter <equinox@diac24.net>
Subject: Re: Introducing open source MSTP daemon
Date: Wed, 1 Feb 2012 06:56:19 +0100
Message-ID: <20120201055619.GB602485@jupiter.n2.diac24.net>
References: <201109221727.33010.vitas@nppfactor.kiev.ua>
 <20110922163939.GB1012103@jupiter.n2.diac24.net>
 <201109281256.19713.vitas@nppfactor.kiev.ua>
 <loom.20120131T103325-267@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: augusto <augusto@proscend.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:37292 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039Ab2BAF43 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 00:56:29 -0500
Content-Disposition: inline
In-Reply-To: <loom.20120131T103325-267@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2012 at 09:38:33AM +0000, augusto wrote:
> I am trying to implement your solution on an embedded system, but I dont have a 
> clear idea of how to use it.
> 
> My scenario is like this:
> 
> eth0.2 and eth1.2 belong to br1
> eth0.4 and eth3.4 belong to br2
> eth1.5 and eth3.5 belong to br3
> 
> I added br1 br2 and br3 to bridge-stp.
> 
> What steps should I take now?

None. The Linux kernel bridge only supports 802.1D bridging / [R]STP,
but not 802.1Q bridging / MSTP kernel part.

You can add eth0 & eth1 to a bridge and put the VLANs on the bridge
(br0.2 / br0.4 / br0.5). That would be a .1D bridge, then.

Or, you can take a look at OpenVSwitch, no idea if it does .1Q/MSTP.


-David
