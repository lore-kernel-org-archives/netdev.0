From: Christian <cjs@dhp.com>
Subject: Re: skb_over_panic kernel panic
Date: Fri, 13 Mar 2009 17:36:02 -0400
Message-ID: <20090313213602.GF13612@dhp.com>
References: <20090311011013.GC7022@dhp.com> <20090313212255.GA28021@electric-eye.fr.zoreil.com>
Reply-To: Christian <cjs@dhp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmmtao105.cox.net ([68.230.240.47]:57698 "EHLO
	eastrmmtao105.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753719AbZCMVgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 17:36:08 -0400
Content-Disposition: inline
In-Reply-To: <20090313212255.GA28021@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes I booted without loading the nvidia module and have the same
problem.

On Fri, Mar 13, 2009 at 10:22:55PM +0100, Francois Romieu wrote:
> Christian <cjs@dhp.com> :
> [...]
> > skb_over_panic: text:fffffffff80456cc4 len:2580 put:2580
> > head:ffff9900bf18a000 data:ffff8800bf18a010 tail:0xa end:0x640 dev:eth0
> > --------[ cut here ] ----------
> > kernel BUG at net/core/skbuff.c:124!xt:ffffffff80456cc4 len:2580
> > put:2580 head:ffff8800bf18a000 data:ffff8800bf18a010 tail:0xa 
> > invalid opcode: 0000 [#1] SMP
> > last sysfs file: /sys/devices/pci0000:00/0000:00:1f.0/resource
> > CPU 5
> > Modules linked in nvidia(P)
> > Pid: 0, comm: swapper Tainted: P        2.6.28.7 #3
> [...]
> > # lsmod
> > Module                  Size  Used by
> > nvidia               7797560  0 
> 
> Can you reproduce the bug when nvidia's module is not loaded
> after boot ?
> 
> -- 
> Ueimor
> 
