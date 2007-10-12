From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFD] iptables:  mangle table obsoletes filter table
Date: Fri, 12 Oct 2007 15:23:33 +0200
Message-ID: <470F7555.4090500@trash.net>
References: <200710120031.42805.a1426z@gawab.com> <200710121525.44510.a1426z@gawab.com> <470F6927.9040505@trash.net> <200710121618.51046.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Al Boldi <a1426z@gawab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58330 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754909AbXJLNYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 09:24:09 -0400
In-Reply-To: <200710121618.51046.a1426z@gawab.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Boldi wrote:
> Patrick McHardy wrote:
> 
>>Al Boldi wrote:
>>
>>>Well, for example to stop any transient packets being forwarded.  You
>>>could probably hack around this using mark's, but you can't stop the
>>>implied route lookup, unless you stop it in prerouting.
>>
>>This also works fine in FORWARD with a little extra overhead.
>>If you really have to save resources, you should use PREROUTING/raw
>>to also avoid the creation of a connection tracking entry.
> 
> 
> Yes sure, if you use nat.

Conntrack.

> But can you see how forcing people into splitting 
> their rules across tables adds complexity.  And without ipt_REJECT patch, 
> they can't even use REJECT in prerouting, which forces them to do some 
> strange hacks.
> 
> IMHO, we should make things as easily configurable as possible, and as things 
> stand right now, the filter-table is completely useless for 99% of 
> use-cases.


Sure, as I said, patches to remove the arbitary restrictions to
tables are welcome, but please do this for all targets and
matches which allow this, not only REJECT. And if you include a
seperate (tested) patch for the IPv4 and IPv6 REJECT targets
I'll consider it as well.
