From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2.6.26] ucc_geth: Fix a bunch of sparse warnings
Date: Tue, 06 May 2008 12:18:29 -0400
Message-ID: <482084D5.4090405@pobox.com>
References: <1209751283-25536-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45303 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755884AbYEFQSb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:18:31 -0400
In-Reply-To: <1209751283-25536-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> ucc_geth didn't have anything marked as __iomem.  It was also inconsistent
> with its use of in/out accessors (using them sometimes, not using them other
> times).  Cleaning this up cuts the warnings down from hundreds to just over a
> dozen.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
>  drivers/net/ucc_geth.c         |  276 +++++++++++++++++++++-------------------
>  drivers/net/ucc_geth.h         |   48 ++++---
>  drivers/net/ucc_geth_ethtool.c |    6 -
>  drivers/net/ucc_geth_mii.c     |    4 +-
>  4 files changed, 174 insertions(+), 160 deletions(-)

applied


