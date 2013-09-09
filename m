From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSQ accounting skb->truesize degrades throughput for large
 packets
Date: Mon, 09 Sep 2013 06:47:25 -0700
Message-ID: <1378734444.26319.28.camel@edumazet-glaptop>
References: <20130906101635.GI14104@zion.uk.xensource.com>
	  <1378472268.31445.15.camel@edumazet-glaptop> <522A049A.7000105@citrix.com>
	 <1378486604.31445.34.camel@edumazet-glaptop> <522D9466.6020205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:35976 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753117Ab3IINr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 09:47:27 -0400
Received: by mail-pb0-f53.google.com with SMTP id up15so6095504pbc.40
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 06:47:26 -0700 (PDT)
In-Reply-To: <522D9466.6020205@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-09 at 17:27 +0800, Jason Wang wrote:

> Virtio-net orphan the skb in .ndo_start_xmit() so TSQ can not throttle
> packets in device accurately, and it also can't do BQL. Does this means
> TSQ should be disabled for virtio-net?
> 

If skb are orphaned, there is no way TSQ can work at all.

It is already disabled, so why do you want to disable it ?
