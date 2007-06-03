From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] qla3xxx: device doesnt do hardware checksumming.
Date: Sun, 03 Jun 2007 11:46:10 -0400
Message-ID: <4662E242.500@garzik.org>
References: <20070530212316.407169588@linux-foundation.org> <20070530212512.118483672@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38276 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197AbXFCPrI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2007 11:47:08 -0400
In-Reply-To: <20070530212512.118483672@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Reading the code for ql_hw_csum_setup(), it is obvious that
> this driver is broken for IPV6. The driver sets the NETIF_F_HW_SUM
> flag, but the code for checksum setup only deals with IPV4.
> 
> Compile tested only, no hardware available.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied to #upstream-fixes


