From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iproute2 : fix to catchup with xtables/iptables >= 1.4.2
Date: Mon, 26 Jan 2009 14:25:35 +0100
Message-ID: <497DB9CF.6060408@trash.net>
References: <1232908352.13279.33.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Andreas Henriksson <andreas@fatal.se>,
	Yevgeny Kosarzhevsky <yevg@pisem.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	Denys Fedoryschenko <denys@visp.net.lb>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43791 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbZAZNZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 08:25:39 -0500
In-Reply-To: <1232908352.13279.33.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> Sorry for the long CC (copying all stakeholders)
> 
> Against latest iproute2 git - fixes breakage found with debian and
> certainly with any distro using iptables 1.4.2.
> 
> A small depart from the old ipt - to keep in sync with iptable/xtables
> changes. The old ipt should continue to work for iptables <1.4.1. And
> with this change, no old scripts will break.
>  
> [Breakage will happen again (probably by the time we hit iptables 1.4.3)
> because xtables is still a moving target. There are quiet a few
> functions which really should be part of xtables but are currently not -
> I have labelled them in tc/m_xt.c].

libxtables.so is pretty incomplete, the best thing would be if you'd
move everything you need there so we can avoid any breakage in the
future.
