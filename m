From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] bonding: refuse to change bond type if
 it's used
Date: Mon, 08 Mar 2010 12:16:32 -0800 (PST)
Message-ID: <20100308.121632.232613075.davem@davemloft.net>
References: <20100308175406.GA2834@psychotron.lab.eng.brq.redhat.com>
	<20100308102448.7acfe7c0@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36407
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755587Ab0CHUQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 15:16:13 -0500
In-Reply-To: <20100308102448.7acfe7c0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 8 Mar 2010 10:24:48 -0800

> On Mon, 8 Mar 2010 18:54:06 +0100
> Jiri Pirko <jpirko@redhat.com> wrote:
> 
>> It's not desirable to be able to change the type of net_device in bond device if
>> it's in use by bridge, or vlan, or so. At the moment, there is possible for
>> example to have INFINIBAND bond type in bridge (by adding bond with eth type to
>> a bridge first and then enslave INFINIBAND device).
> 
> Rather than building lots of back pointer dependencies, why not
> have another netdevice notifier that allows other subsystems to
> see the type change and reject it if they care? That way the code
> would be more modular and expandable.

Agreed.
