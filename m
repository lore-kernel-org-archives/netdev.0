From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH UPDATED] bonding: Fix 802.3ad no carrier on "no partner
 found" instance
Date: Wed, 20 Jun 2007 19:13:05 -0400
Message-ID: <4679B481.8020905@garzik.org>
References: <97949e3e0706011316n5d90bb04kf3a2c556af3fbe9d@mail.gmail.com> <466B28D9.6040806@garzik.org> <29862.1181797894@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Laurent Chavey <chavey@google.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45582 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752024AbXFTXNI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 19:13:08 -0400
In-Reply-To: <29862.1181797894@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	Modify carrier state determination for 802.3ad mode to comply
> with section 43.3.9 of IEEE 802.3, which requires that "Links that are
> not successful candidates for aggregation (e.g., links that are attached
> to other devices that cannot perform aggregation or links that have been
> manually configured to be non-aggregatable) are enabled to operate as
> individual IEEE 802.3 links."
> 
> 	Bug reported by Laurent Chavey <chavey@google.com>.  This patch
> is an updated version of his patch that changes the wording of
> commentary and adds an update to the driver version.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> Signed-off-by: Laurent Chavey <chavey@google.com>

applied to #upstream-fixes


