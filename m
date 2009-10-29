From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/6] vlan: Optimize multiple unregistration
Date: Thu, 29 Oct 2009 15:43:13 +0100
Message-ID: <4AE9AA01.3020805@gmail.com>
References: <4AE728A9.2080209@gmail.com> <4AE8A425.1000600@trash.net> <4AE8ADE7.1010909@gmail.com> <4AE99C88.40403@trash.net> <4AE9A554.8030207@trash.net> <4AE9A6F6.5040209@gmail.com> <4AE9A7AA.70107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40141 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbZJ2OnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 10:43:12 -0400
In-Reply-To: <4AE9A7AA.70107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :

> Indeed, but unregister_vlan_dev() destroys the group once the
> count has reached zero, so we must not access it after that.

Well, I hoped call_rcu() callback doesnt fire and kfree(grp) until we e=
xited
from unregister_vlan_dev_alls(), with RTNL locked...
