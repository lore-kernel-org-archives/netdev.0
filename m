From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 4/6] 8390: Split 8390 support into a pausing and a non
 pausing driver core
Date: Fri, 04 Jul 2008 08:50:38 -0400
Message-ID: <486E1C9E.6080802@garzik.org>
References: <200807040643.m646hCdF017240@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk, alan@redhat.com,
	randy.dunlap@oracle.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56397 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752876AbYGDMum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:50:42 -0400
In-Reply-To: <200807040643.m646hCdF017240@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> 
> Only a few ISA controllers need the pausing version of the 8390 core
> while PCMCIA, later ISA and PCI do not. More importantly the ISA delays
> can break non ISA boxes so we must use a different build of 8390.c for
> the two sets of controllers.
> 
> No changes since last time as all the points of concerns raised proved to
> be invalid
> 
> [randy.dunlap@oracle.com: ne2 (MCA) needs both 8390.o and 8390p.o functions]
> Signed-off-by: Alan Cox <alan@redhat.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

applied, after removing the comment as Alan requested


