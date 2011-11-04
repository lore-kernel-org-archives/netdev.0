From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: iproute2 neighboring
Date: Fri, 4 Nov 2011 08:46:22 -0700
Message-ID: <OFD3A98142.1EDCCB6F-ON8825793E.0055C070-8825793E.0056A45E@us.ibm.com>
References: <CAGXs5wUEiS-vpdsCDoyva2Vg9XKBmbJgoPVOXUXD0u9+PzXH=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:52968 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755840Ab1KDPsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 11:48:15 -0400
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Fri, 4 Nov 2011 11:48:12 -0400
In-Reply-To: <CAGXs5wUEiS-vpdsCDoyva2Vg9XKBmbJgoPVOXUXD0u9+PzXH=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Kevin Wilson <wkevils@gmail.com>

> Hi,
> It seems to me that "ip -6 neigh show" does not show multicast entries 
from
> IPv6 neighboring  table. Is there a reason for this ?

Multicast memberships aren't in the neighbor table. The
neighbor table is for translating protocol addresses to
MAC addresses and that translation is fixed for multicast
destinations.

You can see group memberships with "netstat -g". There are also
some data in /proc/net/{dev_mcast,igmp6,mcfilter6} depending on
what you're looking for.

                                                +-DLS
