From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Tue, 05 Jun 2007 18:40:38 -0600
Message-ID: <m1tztlvrsp.fsf@ebiederm.dsl.xmission.com>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:39855 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934321AbXFFAtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 20:49:18 -0400
In-Reply-To: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	(Patrick McHardy's message of "Tue, 5 Jun 2007 16:12:51 +0200 (MEST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Reading through the patches they look usable to me.

Having to patch iproute to create the more interesting network
devices sucks, but that problem seems fundamental.  We might
be able to avoid it if we allowed fields to be reused between
different types of devices but that makes the error checking
trickier, and we aren't likely to have that many types of
devices so there likely isn't much value in generalizing.

I do think we should specify the IFLA_KIND (was: IFLA_NAME) values in
a header file.  So it is easy to get a list of all of the different
kinds and so we don't conflict.

Eric
