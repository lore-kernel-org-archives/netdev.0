From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [PATCH net 1/2] net: dev_queue_xmit_nit: fix skb->vlan_tci field value
Date: Wed, 9 Jan 2013 12:01:06 -0800
Message-ID: <CAOxq_8OsumXX92odrVcREqsLkeUkcS_0uQvbdaTmtyr1HtuTOw@mail.gmail.com>
References: <CAOUgPvRGQ4XQ-HCFzwKi5rFFfC1fJcicH8DxH0pUjAvgxfi7cw@mail.gmail.com>
	<CAOxq_8MXCvGpq4Q0UfxSbWMDNTusrK710fQ11qgfXKWS+zpoZQ@mail.gmail.com>
	<1357712850.27446.28.camel@edumazet-glaptop>
	<CAOxq_8P=yOYGhhJ2_YJT3ya32k7UNjX6d6Qpz+oVfD4d56sJfQ@mail.gmail.com>
	<CAOxq_8P4PLKXn9FOAWyq4zYH5+Yt7DT1mrU2OSQujGCOjBJZYg@mail.gmail.com>
	<1357761063.27446.60.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: tcpdump-workers@lists.tcpdump.org,
	Paul Pearce <pearce@cs.berkeley.edu>, netdev@vger.kernel.org,
	dborkman <dborkman@redhat.com>, edumazet <edumazet@google.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:40691 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932466Ab3AIUBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 15:01:08 -0500
Received: by mail-ee0-f52.google.com with SMTP id d17so1002837eek.11
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2013 12:01:07 -0800 (PST)
In-Reply-To: <1357761063.27446.60.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 9, 2013 at 11:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-01-09 at 11:27 -0800, Ani Sinha wrote:
>
>> This is wrong. Accelerated or not, the kernel code was organized to
>> have the tags in the packet aux data. So I think this is how user land
>> should be coded as well.
>
> You have your opinion, thats good.
>
> My opinion as a kernel developer is that the network tap is here to have
> a copy of the exact frame given to the _device_.
>

It is fine by me if that is how you see it. In that case. the
behaviour can me made symmetric on both TX and RX. Tap processing in
__netif_receive_skb() can be done before vlan_untag() so that taps see
the exact frame received from the _device_ as you put it.

ani
