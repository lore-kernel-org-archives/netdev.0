From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: make ab_arp select active slaves
 as other modes
Date: Wed, 16 Sep 2009 17:05:20 -0700 (PDT)
Message-ID: <20090916.170520.233815224.davem@davemloft.net>
References: <20090831210937.GA3152@psychotron.redhat.com>
	<30814.1253145765@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, nicolas.2p.debian@free.fr
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54420
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760272AbZIQAFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 20:05:04 -0400
In-Reply-To: <30814.1253145765@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Wed, 16 Sep 2009 17:02:45 -0700

> Jiri Pirko <jpirko@redhat.com> wrote:
> 
>>When I was implementing primary_passive option (formely named primary_lazy) I've
>>run into troubles with ab_arp. This is the only mode which is not using
>>bond_select_active_slave() function to select active slave and instead it
>>selects it itself. This seems to be not the right behaviour and it would be
>>better to do it in bond_select_active_slave() for all cases. This patch makes
>>this happen. Please review.
>>
>>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> 	I tried to break this, and couldn't.  Tested with regular
> ethernet interfaces, as well as VLANs, and it does the right thing.
> 
> 	-J
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks everyone.
