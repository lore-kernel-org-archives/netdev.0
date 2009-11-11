From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: sparse noise due to patch "net: fix kmemcheck annotations"
Date: Wed, 11 Nov 2009 21:41:34 +0100
Message-ID: <4AFB217E.2040209@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:33687 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835AbZKKUlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 15:41:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

with above mentioned patch, committed as
14d18a81b5171d4433e41129619c75748b4f4d26, you changed

struct sk_buff {
	...
	__be16 protocol;
	...
}
to
	__be16 protocol:16;

This introduces the following warning from sparse:

include/linux/skbuff.h:357:41: error: invalid bitfield specifier for
type restricted __be16.

So, one checker satisfied, another disturbed?  Any idea how to get this
sparse-clean again?
-- 
Stefan Richter
-=====-==--= =-== -=-==
http://arcgraph.de/sr/
