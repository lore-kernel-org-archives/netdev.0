From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSQ accounting skb->truesize degrades throughput for large
 packets
Date: Fri, 06 Sep 2013 10:00:40 -0700
Message-ID: <1378486840.31445.36.camel@edumazet-glaptop>
References: <20130906101635.GI14104@zion.uk.xensource.com>
	 <1378472268.31445.15.camel@edumazet-glaptop> <522A049A.7000105@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:56669 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832Ab3IFRAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 13:00:41 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so3461097pbc.29
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 10:00:41 -0700 (PDT)
In-Reply-To: <522A049A.7000105@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-06 at 17:36 +0100, Zoltan Kiss wrote:

> So I guess it would be good to revisit the default value of this 
> setting.

If ixgbe requires 3 TSO packets in TX ring to get line rate, you also
can tweak dev->gso_max_size from 65535 to 64000.
