From: arno@natisbad.org (Arnaud Ebalard)
Subject: Missing regression fix in 2.6.34.1
Date: Wed, 07 Jul 2010 09:38:34 +0200
Message-ID: <87lj9nkah1.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David Miller" <davem@davemloft.net>, brian.haley@hp.com,
	netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:39926 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299Ab0GGHiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jul 2010 03:38:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

A regression was introduced after 2.6.34-rc5 (by f4f914b5: net: ipv6
bind to device issue) which breaks Mobile IPv6 support.

It has been noticed after 2.6.34 release and reported on netdev (see
http://thread.gmane.org/gmane.linux.network/162165).

A fix has been pushed upstream (commit 6057fd78 in linus tree) and David
queued it for stable but the fix is not in 2.6.34.1. I think the problem
is just a missing CC: stable@ in David's email.

Can you include it (6057fd78) in next round of stable patches for 2.6.34
(i.e. .2)?

Cheers,

a+
