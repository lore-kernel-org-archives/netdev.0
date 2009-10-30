From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH v3 4/7] fsl_pq_mdio: Add Suport for etsec2.0 devices.
Date: Fri, 30 Oct 2009 12:52:29 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B9503CA@zin33exm22.fsl.freescale.net>
References: <1256826229-529-1-git-send-email-Sandeep.Kumar@freescale.com> <20091029.212142.189578068.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Fleming Andy-AFLEMING" <afleming@freescale.com>,
	"David Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:33995 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbZJ3HWa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 03:22:30 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n9U7MXFr012698
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 00:22:34 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n9U7PsPC009076
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 02:25:55 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20091029.212142.189578068.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>Did you try the bundle I posted yesterday which failed?  This 
>one is identical, you didn't change anything.
>
>This is getting rediculious.
>
>Try again, and when you do take the patches from patchwork at:
>
>	http://patchwork.ozlabs.org/project/netdev/list/
>
>and you try to apply them to net-next-2.6 using git (_not_ 
>'patch', 'patch' is way too lenient about fuzz and line 
>offsets) so that you can see what's happening.
>
>I'm completely ignoring your patch postings until you sort this out.

1. The patch failure is due to the absence of following commit in
net-next-2.6 tree.
	
	commit e72701acbe0b35e52d3f04d442837c06b4e64f1c
	Author: Anton Vorontsov <avorontsov@ru.mvista.com>
	Date:   Wed Oct 14 14:54:52 2009 -0700

	    net: Fix OF platform drivers coldplug/hotplug when compiled
as modules

	    Some OF platform drivers are missing module device tables,
so they won't
	    load automatically on boot. This patch fixes the issue by
adding proper
	    MODULE_DEVICE_TABLE() macros to the drivers.

	Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
      Signed-off-by: David S. Miller <davem@davemloft.net>

2. The git clone DOES NOT show the changes affected by the above patch
3. If we take a log of the affected file(fsl_pq_mdio.c), then it DOES
show the commit/changes 
   (Gitweb:
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=histo
ry;f=drivers/net/fsl_pq_mdio.c;h=6ac4648669728421b934d32646ffbb626128387
6;hb=HEAD)
4. If we take the log of the tree, the same commit is NOT visible. 
  (Gitweb:
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=log)
5. If we take a Snapshot of the tree, the changes to the file are
present. (in the tarball)

To sum up, the Clone and Tree log DOES NOT show the changes.
The Snapshot and file log DOES show it.

We have tried it on multiple machine/tree clones here.
Is there some problem with the Git tree itself?

>
>You cannot have line offsets or fuzz when you send patches 
>that are to be applied by GIT, and that is the problem with patch #4:
>
>davem@sunset:~/src/GIT/net-next-2.6$ patch -p1 <diff patching 
>file drivers/net/fsl_pq_mdio.c Hunk #6 succeeded at 436 with fuzz 1.
>patching file drivers/net/fsl_pq_mdio.h
>
>GIT does not allow line fuzz, you must make absolutely 
>pristine patches, and therefore if you are testing your 
>submission with just 'patch' that absolutely will not work.
No we are using git-am.
We did try this on multiple clones of the net-next-2.6 tree.
>
>Thanks.
>--
>To unsubscribe from this list: send the line "unsubscribe 
>netdev" in the body of a message to majordomo@vger.kernel.org 
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



--

Thanks
Sandeep
