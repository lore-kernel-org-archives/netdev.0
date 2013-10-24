From: David Miller <davem@davemloft.net>
Subject: Re: 16% regression on 10G caused by TCP small queues
Date: Wed, 23 Oct 2013 23:38:16 -0400 (EDT)
Message-ID: <20131023.233816.1396918839771657154.davem@davemloft.net>
References: <20131023192954.3dd9c784@nehalam.linuxnetplumber.net>
	<CADVnQymDr2K7z3yfKpW-H3R3W3NP+iuPQF2eMfeyS6dn-szdgA@mail.gmail.com>
	<CAOaVG15indAxBz7E-T+9MK03indiXBa0UhQZ5j6K5DxYP44Mxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, eric.dumazet@gmail.com,
	dave.taht@bufferbloat.net, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826Ab3JXDiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 23:38:20 -0400
In-Reply-To: <CAOaVG15indAxBz7E-T+9MK03indiXBa0UhQZ5j6K5DxYP44Mxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 23 Oct 2013 20:09:49 -0700

> I will check 3.12, but what about users on 3.10 which is the LTS
> kernel used by most distros?

The fix will be backported to -stable, relax Stephen.
