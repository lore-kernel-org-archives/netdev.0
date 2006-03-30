From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: dcache leak in 2.6.16-git8 II
Date: Thu, 30 Mar 2006 11:36:52 +0100
Message-ID: <20060330103651.GY27946@ftp.linux.org.uk>
References: <200603270750.28174.ak@suse.de> <200603271822.28043.ak@suse.de> <20060327190027.24498e3a.akpm@osdl.org> <200603300026.59131.ak@suse.de> <20060330095048.GW27946@ftp.linux.org.uk> <20060330101256.GX27946@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, bharata@in.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932168AbWC3Kg5@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20060330101256.GX27946@ftp.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BTW, it allows even funnier stuff: instead of "I'd been allocated by <place>"
you can do "I'd passed through <place>".  E.g. if object has different states
you can slap slab_charge_here() in state transitions and /proc/slab_allocators
will count them separately, showing how many objects are in which state, etc.
