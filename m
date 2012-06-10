From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: bnx2x: Added EEE support
Date: Sun, 10 Jun 2012 07:47:13 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A5027223@SJEXCHMB10.corp.ad.broadcom.com>
References: <20120608130921.GA19268@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Dan Carpenter" <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3683 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751045Ab2FJHry convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2012 03:47:54 -0400
In-Reply-To: <20120608130921.GA19268@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The patch c8c60d88c59c: "bnx2x: Added EEE support" from Jun 6, 2012,
> leads to the following warning:
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c:10121
> bnx2x_848x3_config_init()
> 	 error: buffer overflow 'params->req_duplex' 2 <= 4
> 

Hi Dan,

You are right - this is indeed an error, although one that shouldn't
affect any existing bnx2x chip supporting EEE.

I'll send a patch correcting it soon.

Thanks,
Yuval
