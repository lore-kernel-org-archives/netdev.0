From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next V3 2/4] net/dst: Utility functions to build
 dst_metadata without supplying an skb
Date: Fri, 26 Aug 2016 12:31:59 +0200
Message-ID: <20160826123159.5f525fc2@griffin>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
        <1472141627-27339-3-git-send-email-hadarh@mellanox.com>
        <20160825194050.262ddb5f@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53904 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751433AbcHZKiH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 06:38:07 -0400
In-Reply-To: <20160825194050.262ddb5f@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Aug 2016 19:40:50 +0300, Shmulik Ladkani wrote:
> On Thu, 25 Aug 2016 19:13:45 +0300 Hadar Hen Zion <hadarh@mellanox.com> wrote:
> > From: Amir Vadai <amir@vadai.me>
> > 
> > Extract _ip_tun_rx_dst() and _ipv6_tun_rx_dst() out of ip_tun_rx_dst()
> > and ipv6_tun_rx_dst(), to be used without supplying an skb.
> 
> Per this v3, the newly introduced helpers ate named _ip_tun_set_dst and
> _ipv6_tun_set_dst - better alter the log message to reflect that.

And please rename them to start with double underscore to match the
coding style of the rest of the kernel.

Thanks!

 Jiri
