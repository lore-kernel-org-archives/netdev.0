From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ehea: Access iph->tot_len with correct endianness
Date: Fri, 04 Jul 2008 08:15:57 -0400
Message-ID: <486E147D.4090105@garzik.org>
References: <ada7ic5ed26.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, themann@de.ibm.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48140 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753106AbYGDMQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:16:00 -0400
In-Reply-To: <ada7ic5ed26.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
> iph->tot_len is stored in network byte order, so access it using
> ntohs().  This doesn't have any real world impact on ehea, since ehea
> only exists for big-endian platfroms (at the moment at least) but fixing
> this gets rid of a sparse warning and avoids having a bad example in the
> tree.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>
> ---
>  drivers/net/ehea/ehea_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

applied this and pasemi_mac patch to 2.6.26.


