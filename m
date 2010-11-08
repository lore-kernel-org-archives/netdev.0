From: David Miller <davem@davemloft.net>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via
 /proc
Date: Sun, 07 Nov 2010 18:01:08 -0800 (PST)
Message-ID: <20101107.180108.71121019.davem@davemloft.net>
References: <201011072248.oA7MmjKg025857@cmf.nrl.navy.mil>
	<1289172456.3090.184.camel@Dan>
	<20101107235610.GE17592@basil.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drosenberg@vsecurity.com, chas3@users.sourceforge.net,
	tytso@mit.edu, torvalds@linux-foundation.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com,
	netdev@vger.kernel.org, security@kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47925
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753055Ab0KHCAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 21:00:44 -0500
In-Reply-To: <20101107235610.GE17592@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 8 Nov 2010 00:56:10 +0100

> I would just remove the pointers from /proc and supply 
> gdb macros that extract the equivalent information from /proc/kcore.
> This is a bit racy, but for debugging it should be no
> problem to run them multiple times as needed.

I do not think at all that this is tenable for the kind of
things people use the socket pointers for when debugging
problems.

I defeinitely prefer the inode number to this idea.
