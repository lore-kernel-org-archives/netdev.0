From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: if_arp.h missing in iproute2
Date: Wed, 26 Aug 2009 09:41:53 -0700
Message-ID: <20090826094153.33a86347@nehalam>
References: <4A955DBF.60006@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44633 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750935AbZHZQl4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 12:41:56 -0400
In-Reply-To: <4A955DBF.60006@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Aug 2009 18:07:27 +0200
Oliver Hartkopp <oliver@hartkopp.net> wrote:

> Hello Stephen,
> 
> while compiling the latest iproute2 git with an embedded BSP that had standard
> includes from 2.6.23, it complained about a missing APRHRD_CAN definition.
> 
> The BSP compiles a 2.6.27.8 Kernel but obviously does not use it's includes.
> 
> Adding a recent if_arp.h to iproute2/include/linux/ fixed the problem.
> 
> Is there any reason, why if_arp.h is not in the iproute2 git while all the
> other relevant stuff can be found there?
> 
> Regards,
> Oliver

okay added sanitized version to git

-- 
