From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-next-2.6 PATCH] bonding: refuse to change bond type if it's
 used
Date: Mon, 8 Mar 2010 22:35:10 +0100
Message-ID: <20100308213509.GA2875@psychotron.redhat.com>
References: <20100308175406.GA2834@psychotron.lab.eng.brq.redhat.com>
 <20100308102448.7acfe7c0@nehalam>
 <20100308.121632.232613075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2131 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755600Ab0CHVf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 16:35:27 -0500
Content-Disposition: inline
In-Reply-To: <20100308.121632.232613075.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 08, 2010 at 09:16:32PM CET, davem@davemloft.net wrote:
>From: Stephen Hemminger <shemminger@linux-foundation.org>
>Date: Mon, 8 Mar 2010 10:24:48 -0800
>
>> On Mon, 8 Mar 2010 18:54:06 +0100
>> Jiri Pirko <jpirko@redhat.com> wrote:
>> 
>>> It's not desirable to be able to change the type of net_device in bond device if
>>> it's in use by bridge, or vlan, or so. At the moment, there is possible for
>>> example to have INFINIBAND bond type in bridge (by adding bond with eth type to
>>> a bridge first and then enslave INFINIBAND device).
>> 
>> Rather than building lots of back pointer dependencies, why not
>> have another netdevice notifier that allows other subsystems to
>> see the type change and reject it if they care? That way the code
>> would be more modular and expandable.
>
>Agreed.

Fair enough, I will rework this.

Thanks a lot guys for looking at this.

Jirka
