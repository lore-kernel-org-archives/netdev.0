From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 net-next 0/7] Extend socket timestamping API
Date: Sun, 21 May 2017 13:38:04 -0400 (EDT)
Message-ID: <20170521.133804.807660968424723312.davem@davemloft.net>
References: <20170519155241.15817-1-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
        willemb@google.com
To: mlichvar@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45124 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751233AbdEURik (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:38:40 -0400
In-Reply-To: <20170519155241.15817-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Miroslav Lichvar <mlichvar@redhat.com>
Date: Fri, 19 May 2017 17:52:34 +0200

> This patchset adds new options to the timestamping API that will be
> useful for NTP implementations and possibly other applications.
> 
> The first patch specifies a timestamp filter for NTP packets. The second
> patch updates drivers that can timestamp all packets, or need to list
> the filter as unsupported. There is no attempt to add the support to the
> phyter driver.
> 
> The third patch adds two helper functions working with NAPI ID, which is
> needed by the next patch. The fourth patch adds a new option to get a
> new control message with the L2 length and interface index for incoming
> packets with hardware timestamps.
> 
> The fifth patch fixes documentation on number of non-zero fields in
> scm_timestamping and warns about false software timestamps when
> SO_TIMESTAMP(NS) is combined with SCM_TIMESTAMPING.
> 
> The sixth patch adds a new option to request both software and hardware
> timestamps for outgoing packets. The seventh patch updates drivers that
> assumed software timestamping cannot be used together with hardware
> timestamping.
> 
> The patches have been tested on x86_64 machines with igb and e1000e
> drivers.

Series applied, thanks.
