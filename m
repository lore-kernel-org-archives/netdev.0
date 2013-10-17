From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH 0/2] be2net: patch set
Date: Thu, 17 Oct 2013 06:00:10 +0000
Message-ID: <e2c8da3b-1a7e-40fe-a19b-b9f8bbda712e@CMEXHTCAS2.ad.emulex.com>
References: <1381837869-9543-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Sathya Perla <Sathya.Perla@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:48636 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073Ab3JQGAN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 02:00:13 -0400
In-Reply-To: <1381837869-9543-1-git-send-email-sathya.perla@emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf
> Of Sathya Perla
> 
> Pls apply the following fixes to the net tree. Thanks.
> 
> Vasundhara Volam (2):
>   be2net: pass if_id for v1 and V2 versions of TX_CREATE cmd
>   be2net: drop non-tso frames longer than mtu
> 
Dave, I'll re-send this patch-set without the "drop non-tso frames" patch.
Based on Eric's comments, it seems better to place the mtu checks in pktgen and
before ndo_start_xmit() invocation so that all drivers/devices may benefit from the check.

thanks,
-Sathya
