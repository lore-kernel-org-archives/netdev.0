From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH v2 4/7] fsl_pq_mdio: Add Suport for etsec2.0 devices.
Date: Wed, 28 Oct 2009 17:30:02 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B9502EA@zin33exm22.fsl.freescale.net>
References: <12566625182528-git-send-email-sandeep.kumar@freescale.com> <20091028.024325.134189895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:33320 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbZJ1MAI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 08:00:08 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n9SC06kk000078
	for <netdev@vger.kernel.org>; Wed, 28 Oct 2009 05:00:08 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n9SC3N8t021217
	for <netdev@vger.kernel.org>; Wed, 28 Oct 2009 07:03:24 -0500 (CDT)
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

I had rebased and tested on the master branch of the following tree
http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git

(The git protocol clone was not working, hence we used http)
If this is not the right tree, kindly correct me.
I could not find any other net-next-2.6 tree/branch on kernel.org.


I have updated the tree again, (though there is no change)
the last commit on the tree being :

commit b37b62fea1d1bf68ca51818f8eb1035188efd030
Author: Ben Hutchings <bhutchings@solarflare.com>
Date:   Fri Oct 23 08:33:42 2009 +0000

    sfc: Rename 'xfp' file and functions to reflect reality

    The 'XFP' driver is really a driver for the QT2022C2 and QT2025C
PHYs,
    covering both more and less than XFP.  Rename its functions and
    constants to reflect reality and to reduce namespace pollution when
    sfc is a built-in driver.

    Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

 
Also, I have merged it with the latest linux-next tree 
(It is already updated with the net-next-2.6.git)

>Sort this out before submitting this again.

I am working on it.
>
>If you submit once more this same series, and it doesn't apply 
>properly to net-next-2.6, I will flat our ignore your 
>submissions for a week or so.
>

>You are wasting that much of my time by doing this over and over.
I apologize for that.
>
>Get your act together.
>

