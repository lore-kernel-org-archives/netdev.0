From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [patch 18/21] Filesystem: Socket inode defragmentation
Date: Thu, 15 May 2008 22:23:43 +0400
Message-ID: <20080515182343.GA30899@2ka.mipt.ru>
References: <20080510030831.796641881@sgi.com> <20080510030918.882272887@sgi.com> <20080513132810.GA7152@2ka.mipt.ru> <Pine.LNX.4.64.0805151039060.18708@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Mel Gorman <mel@skynet.ie>, andi@firstfloor.org,
	Rik van Riel <riel@redhat.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com
To: Christoph Lameter <clameter@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805151039060.18708@schroedinger.engr.sgi.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2008 at 10:40:11AM -0700, Christoph Lameter (clameter@sgi.com) wrote:
> All inodes are inactivated and put on a lru before they are freed. Those 

I have to check my memory, but iput()->destroy_inode() highlights first for sockets...

-- 
	Evgeniy Polyakov
