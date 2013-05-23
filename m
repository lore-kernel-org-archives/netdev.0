From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH] be2net: bug fix on returning an invalid nic descriptor
Date: Thu, 23 May 2013 04:32:40 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C25F97375@CMEXMB1.ad.emulex.com>
References: <1369274302-8118-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Wei Yang <weiyang@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:28053 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916Ab3EWEcm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 00:32:42 -0400
In-Reply-To: <1369274302-8118-1-git-send-email-weiyang@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Yang [mailto:weiyang@linux.vnet.ibm.com]
> 
> In function be_get_nic_desc(), it will go through the descriptor array
> returned from f/w. By comparing the desc_type field, it determines whether
> there is a nic descriptor in the array or not. In the case of no nic descriptor,
> this function should return NULL.
> 
> The code may return an invalide descriptor, when there is no nic descriptor in
> the array and the desc_count is less than MAX_RESOURCE_DESC. In this
> case, even there is no nic descriptor, it will still return the lase descriptor
> since the i doesn't equal to MAX_RESOURCE_DESC.
> 
> This patch fix this issue by returning the descriptor when find it and return
> NULL for other cases.
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> Reviewed-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Reviewed-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>

Acked-by: Sathya Perla <sathya.perla@emulex.com>

Thanks for the fix.
-Sathya
