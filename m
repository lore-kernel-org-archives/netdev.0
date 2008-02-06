From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 01/24 for-2.6.25] DM9000: Fix endian-ness of data accesses.
 Patch from: Laurent Pinchart <laurentp@cse-semaphore.com>
Date: Wed, 06 Feb 2008 06:46:34 -0500
Message-ID: <47A99E1A.3050808@garzik.org>
References: <20080205000159.432081941@fluff.org.uk> <20080205000814.539308209@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40870 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761338AbYBFLqh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 06:46:37 -0500
In-Reply-To: <20080205000814.539308209@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

two comments:

1) you should be using __le16 type

2) seems like you should do the same for RxStatus, rather than splitting it


