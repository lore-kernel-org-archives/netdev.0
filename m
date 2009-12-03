From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/4] llc: use a device based hash table to speed up
 multicast delivery
Date: Thu, 3 Dec 2009 15:25:13 -0800
Message-ID: <20091203152513.643c471a@nehalam>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com>
	<1259879498-27860-4-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43708 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752041AbZLCXZN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 18:25:13 -0500
In-Reply-To: <1259879498-27860-4-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  4 Dec 2009 00:31:37 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> This patch adds a per SAP device based hash table to solve the
> multicast delivery scalability issues for the case where the are a
> large number of interfaces and a large number of sockets (bound to the
> same SAP) are used.

Rather than adding hash table and rwlock, why not hash list RCU
and a single spin lock

-- 
