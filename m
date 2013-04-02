From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: GRE: Refactor GRE tunneling code.
Date: Tue, 2 Apr 2013 09:34:21 +0300
Message-ID: <20130402063421.GA4826@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44744 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758104Ab3DBGgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 02:36:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pravin,

I had a question about c54419321455: "GRE: Refactor GRE tunneling code."
from Mar 25, 2013:

net/ipv4/ip_gre.c
   392                  if (tpi->flags&TUNNEL_CSUM &&
   393                      !(skb_shinfo(skb)->gso_type & SKB_GSO_GRE)) {
   394                          *(__sum16 *)ptr = 0;
   395                          *(__sum16 *)ptr = csum_fold(skb_checksum(skb, 0,
   396                                                                   skb->len, 0));

What are we doing here when we set *ptr = 0 and then reset it on the
next line?  Is there a ptr++ or ptr-- missing?

   397                  }

regards,
dan carpenter
