From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 3/5] sundance: solve host error problem in low performance
 embedded system when continune down and up
Date: Tue, 14 Nov 2006 10:40:46 -0500
Message-ID: <4559E37E.1050705@garzik.org>
References: <200611090349.kA93nCaI003597@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40384 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S966026AbWKNPkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 10:40:52 -0500
To: akpm@osdl.org
In-Reply-To: <200611090349.kA93nCaI003597@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Jesse Huang <jesse@icplus.com.tw>
> 
> Solve host error problem in low performance embedded system when continune
> down and up.  It will cause IP100A DMA TargetAbort.  So we need more safe
> process to up and down IP100A with wait hardware completely stop and software
> cur_tx/ dirty_tx/cur_task/last_tx be clear.
> 
> Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

applied


