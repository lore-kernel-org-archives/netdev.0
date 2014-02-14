From: David Howells <dhowells@redhat.com>
Subject: Does ICMP_FRAG_NEEDED automatically update the routing cache?
Date: Fri, 14 Feb 2014 14:36:48 +0000
Message-ID: <26474.1392388608@warthog.procyon.org.uk>
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752071AbaBNOgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 09:36:51 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s1EEan8v012159
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 09:36:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Am I reading the ipv4 code right?  If a UDP packet we send results in an
ICMP_FRAG_NEEDED packet being received, the cached routing information for the
peer will automatically be updated by __udp4_lib_err()?

And something similar in __udp6_lib_err()?

David
