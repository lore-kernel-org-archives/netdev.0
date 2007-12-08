From: David Miller <davem@davemloft.net>
Subject: 'default' vs. 'all'
Date: Sat, 08 Dec 2007 00:04:29 -0800 (PST)
Message-ID: <20071208.000429.66028544.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshifuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40290
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756742AbXLHIE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 03:04:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Herbert, Yoshifuji and I were just discussing the
sysfs device attribute issue.

It's seems sane to me that if we had some kind of
'dirty' bit per attribute we could propagate default
settings everywhere except where the dirty bit had
been set.

The question is how to implement this nicely.

What do you think?
