From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
Date: Tue, 06 Apr 2010 19:47:37 +0200
Message-ID: <1270576057.2081.100.camel@edumazet-laptop>
References: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local>
	 <1270502993.9013.36.camel@edumazet-laptop>
	 <2fefb2a2-d0dc-461d-ac8c-3e7d177b7cf8@VA3EHSMHS032.ehs.local>
	 <1270573233.2081.47.camel@edumazet-laptop>
	 <bf8eac92-5008-4c1f-9b99-0199e62436fa@SG2EHSMHS010.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	john.williams@petalogix.com, michal.simek@petalogix.com,
	John Tyner <jtyner@cs.ucr.edu>
To: John Linn <John.Linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:34483 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756735Ab0DFRrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 13:47:43 -0400
Received: by bwz1 with SMTP id 1so133317bwz.21
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 10:47:40 -0700 (PDT)
In-Reply-To: <bf8eac92-5008-4c1f-9b99-0199e62436fa@SG2EHSMHS010.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Yes I see how it's used, but it only allows you to reserve 2 bytes in the skb with no options.


Really ? This would be a bug !

__alloc_skb() uses kmalloc(XXXX), this gives you the guarantee you want,
or maybe comment you wrote is not what is _really_ necessary ?

/* Align the IP data in the packet on word boundaries as MicroBlaze
 * needs it.
 */


