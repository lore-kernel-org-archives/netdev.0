From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][2/2] Add ICMPMsgStats MIB (RFC 4293)
Date: Tue, 11 Sep 2007 17:50:53 +0900 (JST)
Message-ID: <20070911.175053.104206872.yoshfuji@linux-ipv6.org>
References: <OF6477A060.C15FF1F3-ON88257353.000D3AA5-88257353.000D637A@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43978 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932256AbXIKItZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 04:49:25 -0400
In-Reply-To: <OF6477A060.C15FF1F3-ON88257353.000D3AA5-88257353.000D637A@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <OF6477A060.C15FF1F3-ON88257353.000D3AA5-88257353.000D637A@us.ibm.com> (at Mon, 10 Sep 2007 20:27:03 -0600), David Stevens <dlstevens@us.ibm.com> says:

> These patches "remove" (but not really) the existing counters, and
> replace them with the ICMPMsgStats tables for v4 and v6.
> It includes the named counters in the /proc places they were, but gets the
> values for them from the new tables. It also counts packets generated
> from raw socket output (e.g., OutEchoes, MLD queries, RA's from
> radvd, etc).

Dave, we've been supporting per-interface stats for IPv6, and
you seem to remove them.  Please keep them.  Thank you.

--yoshfuji
