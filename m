From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] IPv4: thresholds in fib_trie.c are not
 modified, make them const
Date: Wed, 12 Dec 2007 10:58:33 -0800 (PST)
Message-ID: <20071212.105833.237798467.davem@davemloft.net>
References: <20071212110555.GA11638@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42532
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752048AbXLLS6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 13:58:34 -0500
In-Reply-To: <20071212110555.GA11638@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 12 Dec 2007 14:05:55 +0300

> -static int halve_threshold = 25;
> -static int inflate_threshold = 50;
> -static int halve_threshold_root = 15;
> -static int inflate_threshold_root = 25;

halve_threshold_root and inflate_threshold_root have different
values in the net-2.6.25 tree.

What tree are you patching against?  These were changed way
back in:

commit 965ffea43d4ebe8cd7b9fee78d651268dd7d23c5
Author: Robert Olsson <robert.olsson@its.uu.se>
Date:   Mon Mar 19 16:29:58 2007 -0700

    [IPV4]: fib_trie root node settings
    
    The threshold for root node can be more aggressive set to get
    better tree compression. The new setting mekes the root grow
    from 16 to 19 bits and substansial improvemnt in Aver depth
    this with the current table of 214393 prefixes
    
    But really the dynamic resize should need more investigation
    both in terms convergence and performance and maybe it should
    be possible to change...
    
    Maybe just for the brave to start with or we may have to back
    this out.

Please don't waste my time like this.  Always submit patches
against the current tree, even if you "think" the files
you are patching haven't changed.
