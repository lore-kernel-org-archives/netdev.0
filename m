From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next] bonding: add slave_changelink support and use
 it for queue_id
Date: Fri, 29 Aug 2014 13:27:08 +0200
Message-ID: <5400638C.2030502@redhat.com>
References: <1409148406-5576-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752016AbaH2L1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 07:27:24 -0400
In-Reply-To: <1409148406-5576-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2014 04:06 PM, Nikolay Aleksandrov wrote:
> This patch adds support for slave_changelink to the bonding and uses it
> to give the ability to change the queue_id of the enslaved devices via
> netlink. It sets slave_maxtype and uses bond_changelink as a prototype for
> bond_slave_changelink.
> Example/test command after the iproute2 patch:
>  ip link set eth0 type bond_slave queue_id 10
> 
> CC: David S. Miller <davem@davemloft.net>
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> 
> Suggested-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---

Hi Dave,
Would you mind telling me why did this patch get rejected so I can fix it up ?
I didn't see any complains and Jiri acked it.

Thanks,
 Nik
