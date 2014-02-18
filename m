From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH v5 net-next 02/12] bonding: permit using arp_validate
 with non-ab modes
Date: Tue, 18 Feb 2014 12:21:46 +0100
Message-ID: <5303424A.2020700@redhat.com>
References: <1392706127-28390-1-git-send-email-vfalico@redhat.com> <1392706127-28390-3-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57563 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217AbaBRLVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 06:21:51 -0500
In-Reply-To: <1392706127-28390-3-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2014 07:48 AM, Veaceslav Falico wrote:
> Currently it's disabled because it's sometimes hard, in typical configs, to
> make it work - because of the nature how the loadbalance modes work - as
> it's hard to deliver valid arp replies to correct slaves by the switch.
> 
> However we still can use arp_validation in loadbalance with several other
> configs, per example with arp_validate == 2 for backup with one broadcast
> domain, without the switch(es) doing any balancing - this way we'd be (a
> bit more) sure that the slave is up.
> 
> So, enable it to let users decide which one works/suits them best. Also
> correct the mode limitation from BOND_OPT_ARP_VALIDATE.
> 
> CC: Nikolay Aleksandrov <nikolay@redhat.com>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---

Acked-by: Nikolay Aleksandrov <nikolay@redhat.com>
