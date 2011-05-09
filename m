From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next-2.6] vlan: remove one synchronize_net() call
Date: Mon, 9 May 2011 10:30:25 -0700
Message-ID: <BANLkTikDXqQtOh4iM04Ek-CEwLHnZFrOiQ@mail.gmail.com>
References: <1304948155.3342.32.camel@edumazet-laptop> <1304952044.3342.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:62167 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445Ab1EIRaq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 13:30:46 -0400
Received: by qyk7 with SMTP id 7so1159793qyk.19
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 10:30:45 -0700 (PDT)
In-Reply-To: <1304952044.3342.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 9, 2011 at 7:40 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> At VLAN dismantle phase, unregister_vlan_dev() makes one
> synchronize_net() call after vlan_group_set_device(grp, vlan_id, NULL=
).
>
> This call can be safely removed because we are calling
> unregister_netdevice_queue() to queue device for deletion, and this
> process needs at least one rcu grace period to complete.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Ben Greear <greearb@candelatech.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Jesse Gross <jesse@nicira.com>
> Cc: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

Acked-by: Jesse Gross <jesse@nicira.com>
