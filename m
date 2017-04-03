From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv4: fix multipath RTM_GETROUTE behavior when iif
 is given
Date: Mon, 3 Apr 2017 13:33:39 -0400
Message-ID: <26f917bb-d44a-e397-1145-58d5e4e823f3@cumulusnetworks.com>
References: <20170403144609.18716-1-fl@n621.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Florian Larysch <fl@n621.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33739 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751808AbdDCRdl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 13:33:41 -0400
Received: by mail-pg0-f42.google.com with SMTP id x125so126835011pgb.0
        for <netdev@vger.kernel.org>; Mon, 03 Apr 2017 10:33:41 -0700 (PDT)
In-Reply-To: <20170403144609.18716-1-fl@n621.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/17 10:46 AM, Florian Larysch wrote:
> inet_rtm_getroute synthesizes a skeletal ICMP skb, which is passed to
> ip_route_input when iif is given. If a multipath route is present for
> the designated destination, ip_multipath_icmp_hash ends up being called,

that function no longer exists since Nik's recent work
(bf4e0a3db97eb882368fd82980b3b1fa0b5b9778)

So does the problem you noted still exist?
