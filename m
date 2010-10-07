From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH V2] Use firmware provided index to register a network
 interface
Date: Thu, 7 Oct 2010 18:49:06 +0200
Message-ID: <20101007164906.GB122295@jupiter.n2.diac24.net>
References: <20101007142319.GB2641@libnet-test.oslab.blr.amer.dell.com>
 <20101007151134.GA25713@kroah.com>
 <20101007163113.GA14260@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Narendra_K@Dell.com,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, Jordan_Hargrave@Dell.com,
	Vijay_Nijhawan@Dell.com, Charles_Rose@Dell.com
To: Matt Domsch <Matt_Domsch@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:52299 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751930Ab0JGQtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Oct 2010 12:49:36 -0400
Content-Disposition: inline
In-Reply-To: <20101007163113.GA14260@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matt,

On Thu, Oct 07, 2010 at 11:31:13AM -0500, Matt Domsch wrote:
> At most, they'll have to deal with the same "eth0_rename"

Getting that "eth0_rename" stuff is not something unchangeably imposed
by the kernel. I think this should be considered an udev bug most of all
things, since if the udev scripts did it right, this wouldn't happen. A
"right" way to do this would for example be to first rename all devices
to "tmpwhatever0", then rename them back to their proper ethX names.

Now I don't know even a single bit about udev scripting, so maybe this
isn't possible with the current udev infrastructure, but there's
certainly no kernel part stopping a proper implementation.

Btw, what happened to nameif(8)? It's totally outdated (and deprecated I
guess?), but it got the job done...


-David

