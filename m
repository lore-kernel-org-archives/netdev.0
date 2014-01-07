From: Thomas Haller <thaller@redhat.com>
Subject: [PATCH v2 0/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of IP6 routes
Date: Tue,  7 Jan 2014 15:39:11 +0100
Message-ID: <1389105553-21230-1-git-send-email-thaller@redhat.com>
References: <1389029375-17698-1-git-send-email-thaller@redhat.com>
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com,
	Thomas Haller <thaller@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46741 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840AbaAGOjh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 09:39:37 -0500
In-Reply-To: <1389029375-17698-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now, the IFA_F_NOPREFIXROUTE flag is saved in ifp->flags.
The second patch reworks the deletion of addresses/cleanup of prefix
routes and considers IFA_F_NOPREFIXROUTE.

Thomas Haller (2):
  ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of
    IP6 routes
  ipv6 addrconf: don't cleanup route prefix for IFA_F_NOPREFIXROUTE

 include/uapi/linux/if_addr.h |   1 +
 net/ipv6/addrconf.c          | 206 ++++++++++++++++++++++++++-----------------
 2 files changed, 125 insertions(+), 82 deletions(-)

-- 
1.8.4.2
