From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: netlink: filter particular protocols from
 analyzers
Date: Thu, 05 Sep 2013 15:03:41 -0400 (EDT)
Message-ID: <20130905.150341.1090416835512463609.davem@davemloft.net>
References: <1378396127-8342-1-git-send-email-dborkman@redhat.com>
	<20130905.144442.2085221662776542385.davem@davemloft.net>
	<20130905115755.7aec533c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org, dborkmann@redhat.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756952Ab3IETDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 15:03:44 -0400
In-Reply-To: <20130905115755.7aec533c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 5 Sep 2013 11:57:55 -0700

> If you want filtering, why not add BPF (sk_filter) support to this?

That's one idea.

But using sk_protocol is at least consistent with how AF_PACKET does
things.
