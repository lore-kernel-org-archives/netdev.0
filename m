From: Andi Kleen <ak@suse.de>
Subject: Re: dcache leak in 2.6.16-git8 II
Date: Thu, 30 Mar 2006 00:53:24 +0200
Message-ID: <200603300053.25235.ak@suse.de>
References: <200603270750.28174.ak@suse.de> <200603300026.59131.ak@suse.de> <20060329145013.37c87323.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bharata@in.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751194AbWC2Wx7@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060329145013.37c87323.akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 30 March 2006 00:50, Andrew Morton wrote:

> It looks that way.  Didn't someone else report a sock_inode_cache leak?

Didn't see it.
 
> > I still got a copy of the /proc in case anybody wants more information.
> 
> We have this fancy new /proc/slab_allocators now, it might show something
> interesting.  It needs CONFIG_DEBUG_SLAB_LEAK.

I didn't have that enabled unfortunately. I can try it on the next round.

-Andi
