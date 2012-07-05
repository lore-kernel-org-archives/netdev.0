From: <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH 1/2] be2net: Fix Endian
Date: Wed, 4 Jul 2012 21:00:41 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F647C6CE076B@EXMAIL.ad.emulex.com>
References: <1341453942-4198-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <roy.qing.li@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:43729 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956Ab2GEEAr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 00:00:47 -0400
In-Reply-To: <1341453942-4198-1-git-send-email-roy.qing.li@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: roy.qing.li@gmail.com [mailto:roy.qing.li@gmail.com]
> Sent: Thursday, July 05, 2012 7:36 AM
> To: netdev@vger.kernel.org
> Cc: Kotur, Somnath
> Subject: [PATCH 1/2] be2net: Fix Endian
> 
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> ETH_P_IP is host Endian, skb->protocol is big Endian, when compare them,
> we should change ETH_P_IP from host endian to big endian, htons, not
> ntohs.
> 
> CC: Somnath Kotur <somnath.kotur@emulex.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Oops!  Unintended...Thanks! 
Acked-by: Somnath Kotur <somnath.kotur@emulex.com>
