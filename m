From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH v2 4/7] fsl_pq_mdio: Add Suport for etsec2.0 devices.
Date: Thu, 29 Oct 2009 15:02:44 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B950352@zin33exm22.fsl.freescale.net>
References: <12566625182528-git-send-email-sandeep.kumar@freescale.com> <20091028.024325.134189895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <avorontsov@ru.mvista.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:49279 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbZJ2Jco convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 05:32:44 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n9T9WlNi007723
	for <netdev@vger.kernel.org>; Thu, 29 Oct 2009 02:32:47 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id n9T9Wk7G000992
	for <netdev@vger.kernel.org>; Thu, 29 Oct 2009 04:32:47 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20091028.024325.134189895.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Wednesday, October 28, 2009 3:13 PM
>To: Kumar Gopalpet-B05799
>Cc: netdev@vger.kernel.org
>Subject: Re: [PATCH v2 4/7] fsl_pq_mdio: Add Suport for 
>etsec2.0 devices.
>
>From: Sandeep Gopalpet <sandeep.kumar@freescale.com>
>Date: Tue, 27 Oct 2009 22:25:18 +0530
>
>> This patch adds mdio support for etsec2.0 devices.
>> 
>> Modified the fsl_pq_mdio structure to include the new mdio members.
>> 
>> Signed-off-by: Sandeep Gopalpet <sandeep.kumar@freescale.com>
>
>This is the third time you've submitted this patch, and for 
>the third time it DOES NOT apply to net-next-2.6 at all when I 
>try to apply this gianfar patch series.
>
>You must be patching against another tree that has some 
>changes that conflict with this one.
>
>Sort this out before submitting this again.
>
>If you submit once more this same series, and it doesn't apply 
>properly to net-next-2.6, I will flat our ignore your 
>submissions for a week or so.
>
>You are wasting that much of my time by doing this over and over.
>
>Get your act together.
>
>

 
Hi All,

I couldn't find the following commit on the net-next-2.6 tree:

commit e72701acbe0b35e52d3f04d442837c06b4e64f1c
Author: Anton Vorontsov <avorontsov@ru.mvista.com>
Date:   Wed Oct 14 14:54:52 2009 -0700

    net: Fix OF platform drivers coldplug/hotplug when compiled as
modules

    Some OF platform drivers are missing module device tables, so they
won't
    load automatically on boot. This patch fixes the issue by adding
proper
    MODULE_DEVICE_TABLE() macros to the drivers.

    Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


The same commit is present on the linux-next tree

I cloned the 2 trees from the following links:
linux-next from:

http://www.kernel.org/pub/scm/linux/kernel/git/sfr/linux-next.git/

And net-next-2.6 from:

http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git

The absence of the above mentioned commit in the net-next-2.6 tree is
causing
some issues with patches getting applied.

Can you let me know if the net-next-2.6 tree that I am cloning is the
proper one ?


I based all my patches on net-next-2.6 tree cloned from the above link.
But some how when David tries to apply
my patches they fail. I took a diff at the linux-next and net-next-2.6
and the said commit is missing.


-Thanks
Sandeep 
