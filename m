From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RAW6: Do not allow set IPV6_CHECKSUM for ICMPv6 socket
Date: Sun, 20 Apr 2008 00:33:28 -0700 (PDT)
Message-ID: <20080420.003328.45324753.davem@davemloft.net>
References: <480878CE.5040904@cn.fujitsu.com>
	<20080418.040949.87112742.davem@davemloft.net>
	<480AEE5C.4090402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43117
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751456AbYDTHd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 03:33:26 -0400
In-Reply-To: <480AEE5C.4090402@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Sun, 20 Apr 2008 15:18:52 +0800

> Why not remove the RFC-breaking code from applications?

Because once applications exist and are deployed we cannot break them
with careless kernel changes.  A user should not get a broken
traceroute6 binary just because he upgrades his kernel, that's
a bug.

The RFC is not a set of laws that must be followed under all
circumstances.  In this case it is worse to break applications on
people's systems than be compliant to some standard.

You need to understand this basic premise before we can communicate at
all about this topic.
