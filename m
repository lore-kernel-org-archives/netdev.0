From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/1] qeth: fix build error caused by VLAN changes
Date: Tue, 22 Jul 2008 16:09:42 -0400
Message-ID: <48863E86.90204@pobox.com>
References: <20080722073924.165257000@de.ibm.com> <20080722074014.988096000@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	bunk@kernel.org, kaber@trash.net
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48694 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752566AbYGVUJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 16:09:49 -0400
In-Reply-To: <20080722074014.988096000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

frank.blaschka@de.ibm.com wrote:
> Adrian Bunk reports this build error:
> 
> CC      drivers/s390/net/qeth_l3_main.o
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c:
> In function 'qeth_l3_hard_start_xmit':
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c:
> 2654: error: implicit declaration of function 'VLAN_TX_SKB_CB'
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c:
> 2654: error: invalid type argument of '->' (have 'int')
> make[3]: *** [drivers/s390/net/qeth_l3_main.o] Error 1
> 
> The intention of the driver appears to be to invalidate the VLAN tag.
> Change it to set skb->vlan_tci to zero, which has the same effect.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
> ---
>  drivers/s390/net/qeth_l3_main.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

applied


