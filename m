From: "Andy Johnson" <johnsonzjo@gmail.com>
Subject: A question about hh_cache
Date: Sun, 30 Dec 2007 15:31:53 +0200
Message-ID: <147a89290712300531m4a8845betd23ef71f6d944799@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:4711 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017AbXL3Nby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2007 08:31:54 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2403423fga.17
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2007 05:31:53 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

struct neighbour has a member named hh_cache; this
hh_cache caches link layer headers to speed up transmission
(instead filling them again and again for each packet).

The hh_cache struct is defined in linux/netdev.h.
Its first member is hh_next, which is a pointer to
hh_cache.
I tried to think of scenarios where this hh_next pointer is used,
and could not think of anything.

Each neighbour has one ip address (the primary key), so it has one
dev member (which is the net_device on which that primary key is configured),
so it has one mac address (which is the dev_addr of net_device).
So there should be only one entry in that hh_cache ; it should be
the entry which its hh_data (the ethernet header) is composed from the
dev_addr, the source MAC address, and the type.

Can anybody give an example when hh_cache of a neighbour instance is a
list with more than
one entry ?

Regards,
Johnson
