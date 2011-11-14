From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESUBMIT2 net-next 1/2] IPv6 routing, NLM_F_* flag
 support: warn if NEWROUTE lacks of both CREATE and REPLACE flags
Date: Mon, 14 Nov 2011 02:06:17 -0500 (EST)
Message-ID: <20111114.020617.136865443034405914.davem@davemloft.net>
References: <1321254611.23935.15.camel@hakki>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matti.vaittinen@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897Ab1KNHGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 02:06:24 -0500
In-Reply-To: <1321254611.23935.15.camel@hakki>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These changes still has problems.

These warning messages are poorly formatted.  Some of them don't even indicate
that ipv6 is involved by printing out an appropriate subsystem prefix.

And frankly, they are ugly, and not the kind of thing I want the networking
code spitting out.

Consolidate these messages into something that has good form and will indicate,
consistently, where the trouble is occuring.

And I still submit that perhaps these ugly messages are an indicate of how
bad an idea these changes are in the first place.  We've lived with the
current behavior for 15 years or more, nobody cared.  What changed?
What can't you do with the current setup?  And why can't you do it without
requiring operations that work currently to change semantics?
