From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Fri, 02 Feb 2007 16:50:35 -0500
Message-ID: <45C3B22B.4020400@hp.com>
References: <20070129213013.GA26841@hmsreliant.homelinux.net> <20070130.072536.129403235.yoshfuji@linux-ipv6.org> <20070130130208.GA3723@hmsreliant.homelinux.net> <20070131.011629.84005028.yoshfuji@linux-ipv6.org> <20070131205443.GA12237@hmsreliant.homelinux.net> <20070202190634.GA29001@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:56289 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946097AbXBBVuk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 16:50:40 -0500
In-Reply-To: <20070202190634.GA29001@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil Horman wrote:
> Ok, I'm still testing it, but heres a new patch for review.  Significant changes
> include the addition of a CONFIG_IPV6_OPTIMISTIC_DAD option that is dependent on
> the inclusion of both IPPV6 and EXPERIMENTAL options, as well as a new method
> for redirecting packets from optimistic sources to incomplete neighbors by
> instead looking up a default router in ip6_dst_lookup_tail, as I described in my
> previous note.
> 

Hi Neil

Still digesting the routing changes, but I think you missed addrconf_prefix_rcv()... ;)


-vlad
