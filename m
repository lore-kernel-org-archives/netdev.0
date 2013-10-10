From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH next 2/6] be2net: pass if_id for v1 and V2 versions of
 TX_CREATE cmd
Date: Thu, 10 Oct 2013 10:53:41 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C26A275D8@CMEXMB1.ad.emulex.com>
References: <1380623401-15630-1-git-send-email-sathya.perla@emulex.com>
 <1380623401-15630-3-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:54927 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205Ab3JJKxl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 06:53:41 -0400
In-Reply-To: <1380623401-15630-3-git-send-email-sathya.perla@emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf
> 
> From: Vasundhara Volam <vasundhara.volam@emulex.com>
> 
> It is a required field for all TX_CREATE cmd versions > 0.
> Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

David, Could you pls queue this patch for the stable tree.

This was committed into the net-next tree:
commit 81b0265531b2ff091fb91c0af9bc9675f84e6f56
be2net: pass if_id for v1 and V2 versions of TX_CREATE cmd
Date:   Tue Oct 1 15:59:57 2013 +0530

This patch actually belongs in the net-tree. As it fixes a driver initialization failure on SH-R adapters, it needs to be
queued for stable tree too.
It was a mistake on my part to submit it to the net-next tree.

thanks,
-Sathya
