From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Wed, 06 Jun 2007 15:46:55 +0200
Message-ID: <4666BACF.2070106@trash.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, hadi@cyberus.ca, xemul@sw.ru,
	ebiederm@xmission.com, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54147 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759190AbXFFNrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 09:47:22 -0400
In-Reply-To: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> The following patches contain the rtnetlink link creation API I promised,
> as well as two simple driver conversion to use the API as an example.
> I've also converted VLAN as a more complex example, but these patches
> need some more work and are most likely not interesting to all the CCed
> parties, so I'm sending them seperately.


I've updated the patches to remove the broken VLAN ID change, added back
some consts, renamed IFLA_INFO_NAME to IFLA_INFO_KIND and rebased to
current net-2.6. The current patches and -git trees can be found at
http://people.netfilter.org/kaber/rtnl_link/

