From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC v2 5/7] net: netfilter conntrack - add per-net	functionality
 for TCP protocol
Date: Thu, 26 Mar 2009 16:46:16 +0100
Message-ID: <49CBA348.5070708@trash.net>
References: <20090311205706.141086138@gmail.com> <20090311210817.688725782@gmail.com> <20090316205825.GK7551@localhost> <49CB9BB6.3040004@trash.net> <20090326153747.GB7950@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, daniel.lezcano@free.fr,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, adobriyan@gmail.com
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34974 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758940AbZCZPq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 11:46:27 -0400
In-Reply-To: <20090326153747.GB7950@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cyrill Gorcunov wrote:
> Yes, no problem, wait a bit please.
> 
> Btw, I think the bestest way (and surely more clean)
> would be to use some new form of the sysctl templates.
> 
> But I didn't find such a form of writting which would
> sutisfy me. Since you said those enums are written in
> stone it's safe to use iterative fasion indeed but
> as I see you found them not that "pretty" too :)

I just like the code structure with all definitions and initializations
at the top better. But that obviously isn't possible with network
namespaces, so just ignore me :)

> On the other hand -- if per-net initialization is not
> that critical in speed (ie some speed could be sacrificed
> for the code clarity -- I could play with those templates
> maybe). Just a thought.

For now lets just get this stuff in since I think its about the last
bits for full netfilter namespace support. I'll happily take further
cleanups of course, but I don't think its worth delaying this any
longer.
