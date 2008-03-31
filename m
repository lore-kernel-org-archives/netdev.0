From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Mon, 31 Mar 2008 17:49:03 -0400
Message-ID: <1207000143.4424.167.camel@localhost>
References: <47EAAFEC.6000805@trash.net>	<20080331123311.64e4ca37@extreme>
	 <47F13E43.2040404@trash.net>
	 <20080331.130757.199769025.davem@davemloft.net>
	 <47F1467F.2080407@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.178]:49617 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754951AbYCaVzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 17:55:44 -0400
Received: by el-out-1112.google.com with SMTP id v27so630776ele.17
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2008 14:55:43 -0700 (PDT)
In-Reply-To: <47F1467F.2080407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-31-03 at 22:15 +0200, Patrick McHardy wrote:

> I'll cook something up based on my and Stephen's patches.

Nice - now we can move all the filtering off iproute2;->

My view is that the nature of most stuff to filter on _events_ will
depend on something along a "whodunnit" field. Route messages have a
rudimentary form of such a field (the "protocol" field on the quagga
patch Stephen posted for example uses it). It would be really nice to be
able to generate such a field on all events to emit say the processid of
the process which caused the event. Ive been thinking of adding a
permanent field like that on the actions/filters. What are peoples
thoughts on that?

cheers,
jamal

