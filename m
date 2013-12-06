From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/2] ipv6 addrconf: extend ifa_flags to u32
Date: Fri, 06 Dec 2013 16:35:18 -0500 (EST)
Message-ID: <20131206.163518.1817492341433351545.davem@davemloft.net>
References: <1386319522-2102-1-git-send-email-jiri@resnulli.us>
	<1386319522-2102-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42767 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758386Ab3LFVfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:35:20 -0500
In-Reply-To: <1386319522-2102-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  6 Dec 2013 09:45:21 +0100

> There is no more space in u8 ifa_flags. So do what davem suffested and
> add another netlink attr called IFA_FLAGS for carry more flags.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Thomas Haller <thaller@redhat.com>

Applied, can you extend the handling of this attribute to the other
protocols as I asked you to?
