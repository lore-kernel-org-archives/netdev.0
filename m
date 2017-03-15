From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] net/openvswitch: Set the ipv6 source tunnel key
 address attribute correctly
Date: Wed, 15 Mar 2017 17:28:59 +0100
Message-ID: <20170315172859.6c953e7f@griffin>
References: <1489594247-8601-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Paul Blakey <paulb@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, mlxsw@mellanox.com,
        netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40032 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752578AbdCOQ3J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 12:29:09 -0400
In-Reply-To: <1489594247-8601-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Mar 2017 18:10:47 +0200, Or Gerlitz wrote:
> When dealing with ipv6 source tunnel key address attribute
> (OVS_TUNNEL_KEY_ATTR_IPV6_SRC) we are wrongly setting the tunnel
> dst ip, fix that.
> 
> Fixes: 6b26ba3a7d95 ('openvswitch: netlink attributes for IPv6 tunneling')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Reported-by: Paul Blakey <paulb@mellanox.com>

Acked-by: Jiri Benc <jbenc@redhat.com>

> Jiri, so I have few wild guesses how things work w.o this fix, e.g: 
> 
> (1) typically the tunnel source ip attribute isn't set by user-space

I think this is it.

Thanks for the fix!

 Jiri
