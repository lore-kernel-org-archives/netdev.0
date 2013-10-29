From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Mon, 28 Oct 2013 20:12:04 -0400 (EDT)
Message-ID: <20131028.201204.981076031206439685.davem@davemloft.net>
References: <20131028.171725.1076499130782328273.davem@davemloft.net>
	<1383002179.28991.14.camel@dcbw.foobar.com>
	<1383002583.28991.19.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, jiri@resnulli.us, vyasevich@gmail.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38891 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546Ab3J2AMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 20:12:06 -0400
In-Reply-To: <1383002583.28991.19.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Mon, 28 Oct 2013 18:23:03 -0500

> Except that we've run out of IFA_F_* flags already, since it's a u8 and
> there are already 8 flags.  What to do?

That's not a problem, just add a new netlink attribute "extended
flags" that can be passed in with address netlink messages.
