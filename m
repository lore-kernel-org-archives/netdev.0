From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: use of bool in exported headers?
Date: Fri, 18 Jul 2008 11:07:30 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0807181106200.12734@fbirervta.pbzchgretzou.qr>
References: <0FE8A686-5F80-4868-8C85-5E82EA9EF2D1@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:38794 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbYGRJHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 05:07:31 -0400
In-Reply-To: <0FE8A686-5F80-4868-8C85-5E82EA9EF2D1@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2008-07-18 08:28, Kumar Gala wrote:

> What's the rule with regards to use of 'bool' in a header exposed to user space
> apps?
>
> We are getting the following compile error w/iptables because of bool in
> include/linux/netfilter/xt_sctp.h:
>
> In file included from extensions/libip6t_sctp.c:24:

Use #include <stdbool.h> in userspace.
