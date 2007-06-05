From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Wed, 06 Jun 2007 00:07:32 +0200
Message-ID: <4665DEA4.3090607@trash.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain> <1181080819.4062.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, xemul@sw.ru,
	ebiederm@xmission.com, tgraf@suug.ch
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38761 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764122AbXFEWHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 18:07:42 -0400
In-Reply-To: <1181080819.4062.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> All patches looked really good. speaking for the ifb stuff, a definete
> ACK. 
> The only thing that threw me off for a sec was the naming convention for
> "type" referenced via IFLA_INFO_NAME because it seems to be colliding
> semantic with dev->type and dev->name as in IFLA_NAME and  
> ifi_type ifinfomsg.
> But i cant come with a better noun. 


How about IFLA_INFO_KIND (borrowed from sch_api)? I generally don't
like the IFLA_INFO_ prefix very much, but so far didn't come up with
something better. Suggestions welcome :)

