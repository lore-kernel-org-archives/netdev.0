From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 18/21] Filesystem: Socket inode defragmentation
Date: Thu, 15 May 2008 10:40:11 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805151039060.18708@schroedinger.engr.sgi.com>
References: <20080510030831.796641881@sgi.com> <20080510030918.882272887@sgi.com>
 <20080513132810.GA7152@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Mel Gorman <mel@skynet.ie>, andi@firstfloor.org,
	Rik van Riel <riel@redhat.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:57102 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751553AbYEORkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 13:40:14 -0400
In-Reply-To: <20080513132810.GA7152@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 May 2008, Evgeniy Polyakov wrote:

> Out of curiosity, how can you drop socket inode, since it is always
> attached to socket which is removed automatically when connection is
> closed. Any force of dropping socket inode can only result in connection
> drop, i.e. there are no inodes, which are placed in cache and are not
> yet freed, if there are no attached sockets.
> 
> So question is how does it work for sockets?

All inodes are inactivated and put on a lru before they are freed. Those 
could be reclaimed by inode defrag. Socket inode defrag is not that 
important. Just shows that this can be applied in a general way.


