From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: skb_over_panic kernel panic
Date: Fri, 13 Mar 2009 22:22:55 +0100
Message-ID: <20090313212255.GA28021@electric-eye.fr.zoreil.com>
References: <20090311011013.GC7022@dhp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Christian <cjs@dhp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55491 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753467AbZCMVTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 17:19:40 -0400
Content-Disposition: inline
In-Reply-To: <20090311011013.GC7022@dhp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christian <cjs@dhp.com> :
[...]
> skb_over_panic: text:fffffffff80456cc4 len:2580 put:2580
> head:ffff9900bf18a000 data:ffff8800bf18a010 tail:0xa end:0x640 dev:eth0
> --------[ cut here ] ----------
> kernel BUG at net/core/skbuff.c:124!xt:ffffffff80456cc4 len:2580
> put:2580 head:ffff8800bf18a000 data:ffff8800bf18a010 tail:0xa 
> invalid opcode: 0000 [#1] SMP
> last sysfs file: /sys/devices/pci0000:00/0000:00:1f.0/resource
> CPU 5
> Modules linked in nvidia(P)
> Pid: 0, comm: swapper Tainted: P        2.6.28.7 #3
[...]
> # lsmod
> Module                  Size  Used by
> nvidia               7797560  0 

Can you reproduce the bug when nvidia's module is not loaded
after boot ?

-- 
Ueimor
