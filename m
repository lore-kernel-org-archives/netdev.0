From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 iproute2] utils: return default family when rtm_family
 is not RTNL_FAMILY_IPMR/IP6MR
Date: Thu, 27 Jul 2017 11:28:45 -0700
Message-ID: <20170727112845.666f9f94@xeon-e3>
References: <1501146109-30032-1-git-send-email-liuhangbin@gmail.com>
        <1501148655-32629-1-git-send-email-liuhangbin@gmail.com>
        <20170727100302.GP2235@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:37327 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751441AbdG0S2r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 14:28:47 -0400
Received: by mail-pg0-f41.google.com with SMTP id y129so101129821pgy.4
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 11:28:47 -0700 (PDT)
In-Reply-To: <20170727100302.GP2235@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Jul 2017 12:03:02 +0200
Phil Sutter <phil@nwl.cc> wrote:

> On Thu, Jul 27, 2017 at 05:44:15PM +0800, Hangbin Liu wrote:
> > When we get a multicast route, the rtm_type is RTN_MULTICAST, but the
> > rtm_family may be AF_INET. If we only check the type with RTNL_FAMILY_IPMR,
> > we will get malformed address. e.g.
> > 
> > + ip -4 route add multicast 172.111.1.1 dev em1 table main
> > 
> > Before fix:
> > + ip route list type multicast table main
> > multicast ac6f:101:800:400:400:0:3c00:0 dev em1 scope link
> > 
> > After fix:
> > + ip route list type multicast table main
> > multicast 172.111.1.1 dev em1 scope link
> > 
> > Fixes: 56e3eb4c3400 ("ip: route: fix multicast route dumps")
> > Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>  
> 
> Acked-by: Phil Sutter <phil@nwl.cc>

Applied, thanks.
