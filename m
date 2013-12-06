From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/2] ipv6 addrconf: introduce
 IFA_F_MANAGETEMPADDR to tell kernel to manage temporary addresses
Date: Fri, 06 Dec 2013 16:35:24 -0500 (EST)
Message-ID: <20131206.163524.1939184522364402939.davem@davemloft.net>
References: <1386319522-2102-1-git-send-email-jiri@resnulli.us>
	<1386319522-2102-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42788 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758386Ab3LFVf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:35:26 -0500
In-Reply-To: <1386319522-2102-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  6 Dec 2013 09:45:22 +0100

> Creating an address with this flag set will result in kernel taking care
> of temporary addresses in the same way as if the address was created by
> kernel itself (after RA receive). This allows userspace applications
> implementing the autoconfiguration (NetworkManager for example) to
> implement ipv6 addresses privacy.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Thomas Haller <thaller@redhat.com>

Applied.
