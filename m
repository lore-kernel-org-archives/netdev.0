From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: IPv6 over firewire
Date: Sat, 12 Jan 2013 14:57:57 +0100
Message-ID: <20130112145757.4ff61f18@stein>
References: <50EF1AEB.1080704@gmail.com>
	<20130110210912.09c62d38@stein>
	<50F10E94.9090302@gmail.com>
	<20130112102452.13babc65@stein>
	<50F140F7.60503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:59578 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921Ab3ALN6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 08:58:15 -0500
In-Reply-To: <50F140F7.60503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 12 Stephan Gatzka wrote:
> >    - There is another downside:  Each new driver method increases the
> >      memory footprint of instances of respective function pointer tables
> >      by 4 or 8 bytes.
> 
> I can't imagine that this is a show stopper. How many instances of 
> struct netdev do we have o a typical system? I guess not the much.

There aren't many instances, but these instances are used in hot paths
where cache utilization matters.  Of course such structures can be ordered
so that often used parts are located close to each other.
-- 
Stefan Richter
-=====-===-= ---= -==--
http://arcgraph.de/sr/
