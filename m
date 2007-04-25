From: Andrew Morton <akpm@linux-foundation.org>
Subject: sysctls
Date: Wed, 25 Apr 2007 12:29:24 -0700
Message-ID: <20070425122924.88391585.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:49480 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751605AbXDYT3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 15:29:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I note that the networking tree is adding new sysctls:

<<<<<<< HEAD/include/linux/sysctl.h
        NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
=======
        NET_IPV6_OPTIMISTIC_DAD=24,
        NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
>>>>>>> /include/linux/sysctl.h

(Well, it's trying to - there are some git rejects in net-2.6.22)

But we kind-of decided a while back to stop doing that and to
use CTL_UNNUMBERED.

Frankly, I don't 100% remember the thinking - Eric, can you please remind
us?
