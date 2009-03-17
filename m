From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 00/04: netfilter fixes
Date: Tue, 17 Mar 2009 13:13:36 -0700 (PDT)
Message-ID: <20090317.131336.135791868.davem@davemloft.net>
References: <20090316160841.3567.94089.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33672
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756467AbZCQUNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 16:13:49 -0400
In-Reply-To: <20090316160841.3567.94089.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 16 Mar 2009 17:08:42 +0100 (MET)

> the following patches for 2.6.29 fix a few netfilter bugs:
> 
> - avoid event delivery for conntracks dropped because of clashes (from Pablo)
> 
> - fix for a ctnetlink crash during expectation creation caused by a missing
>   initialization. Also from Pablo.
> 
> - a fix for correctly handling NF_DROP return values from the conntrack
>   ->packet() callbacks. From Christoph Pasch.
> 
> - reordering of the header checks in IPv6 conntrack reassembly to avoid an
>   incorrect log message with NEXTHDR_NONE. Also from Christoph.
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Pulled, thanks a lot!
