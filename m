From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Virtual ethernet device (tunnel)
Date: Wed, 02 May 2007 15:57:10 +0200
Message-ID: <463898B6.8060503@trash.net>
References: <46386DFB.7090109@sw.ru> <46388562.9050305@trash.net>	<1178110192.4074.55.camel@localhost> <46388B19.70300@trash.net> <m1647bxs1c.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Pavel Emelianov <xemul@sw.ru>,
	David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Kirill Korotaev <dev@sw.ru>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, devel@openvz.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36338 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993205AbXEBN6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 09:58:18 -0400
In-Reply-To: <m1647bxs1c.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> The consensus from the last thread was pretty much that we need
> to implement RTM_NEWLINK and RTM_DELLINK, if it is at all possible.


Yes, as I said, I can take care of this for 2.6.23.

> So that we can get code reuse between different virtual devices.
> Although I suspect we will need some per type attribute parsing.


Yes, we could use IFLA_PROTINFO, but since some devices (for example
bridging) already use a non-nested attribute for this when sending
notifications, its probably better to introduce a new attribute for
device specific stuff to keep things symetrical.

