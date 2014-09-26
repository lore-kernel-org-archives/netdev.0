From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH v3 5/7] net: Add GSO support for UDP tunnels with checksum
Date: Sat, 27 Sep 2014 00:05:19 +0300
Message-ID: <CAJZOPZJTfJtuhWZ91_KOZxr=V7J7KPX5OGeR_7rY52iOjWcEVw@mail.gmail.com>
References: <alpine.DEB.2.02.1406041706450.14949@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:59847 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755839AbaIZVFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 17:05:20 -0400
Received: by mail-qg0-f52.google.com with SMTP id i50so1424422qgf.25
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 14:05:19 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406041706450.14949@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 5, 2014 at 3:20 AM, Tom Herbert <therbert@google.com> wrote:
>
> Added a new netif feature for GSO_UDP_TUNNEL_CSUM. This indicates
> that a device is capable of computing the UDP checksum in the
> encapsulating header of a UDP tunnel.



Tom,

Do we have upstream driver that supports GSO_UDP_TUNNEL_CSUM? did you
had such driver/patch while doing this patches? when a driver
advertizes that bit, should they look over the xmit path on the new
encap_hdr_csum bit?

Or.


>
>  include/linux/netdev_features.h |  1 +
>  include/linux/skbuff.h          |  2 ++
>  net/ipv4/af_inet.c              |  1 +
>  net/ipv4/tcp_offload.c          |  1 +
>  net/ipv4/udp.c                  | 40 +++++++++++++++++++---------------------
>  net/ipv4/udp_offload.c          |  4 +++-
>  net/ipv6/ip6_offload.c          |  1 +
>  net/ipv6/udp_offload.c          |  4 +++-
>  8 files changed, 31 insertions(+), 23 deletions(-)
