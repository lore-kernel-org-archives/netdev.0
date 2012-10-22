From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: bnx2x: Added EEE support
Date: Mon, 22 Oct 2012 15:06:47 +0300
Message-ID: <20121022120647.GC7380@mwanda>
References: <20120608130921.GA19268@elgon.mountain>
 <979A8436335E3744ADCD3A9F2A2B68A5027223@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:26444 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348Ab2JVMHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 08:07:02 -0400
Content-Disposition: inline
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A5027223@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 10, 2012 at 07:47:13AM +0000, Yuval Mintz wrote:
> > The patch c8c60d88c59c: "bnx2x: Added EEE support" from Jun 6, 2012,
> > leads to the following warning:
> > drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c:10121
> > bnx2x_848x3_config_init()
> > 	 error: buffer overflow 'params->req_duplex' 2 <= 4
> > 
> 
> Hi Dan,
> 
> You are right - this is indeed an error, although one that shouldn't
> affect any existing bnx2x chip supporting EEE.
> 
> I'll send a patch correcting it soon.
> 

What happened with this?

regards,
dan carpenter
