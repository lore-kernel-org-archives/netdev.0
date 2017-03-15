From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net] net/openvswitch: Set the ipv6 source tunnel key
 address attribute correctly
Date: Wed, 15 Mar 2017 10:41:14 -0700
Message-ID: <CAPWQB7EYmGi=wvr509Xg6Ahjh6Jmf77=61Om2WCG6SeQvFu6yw@mail.gmail.com>
References: <1489594247-8601-1-git-send-email-ogerlitz@mellanox.com> <20170315172859.6c953e7f@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Paul Blakey <paulb@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, mlxsw@mellanox.com,
        netdev <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:54883 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbdCORlm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 13:41:42 -0400
Received: from mfilter16-d.gandi.net (mfilter16-d.gandi.net [217.70.178.144])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id C4C06C5A67
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:41:37 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter16-d.gandi.net (mfilter16-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id fLn426pvWvW4 for <netdev@vger.kernel.org>;
        Wed, 15 Mar 2017 18:41:36 +0100 (CET)
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
        (Authenticated sender: joe@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 2CA31C5A5F
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:41:36 +0100 (CET)
Received: by mail-qk0-f181.google.com with SMTP id v127so19176140qkb.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 10:41:36 -0700 (PDT)
In-Reply-To: <20170315172859.6c953e7f@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15 March 2017 at 09:28, Jiri Benc <jbenc@redhat.com> wrote:
> On Wed, 15 Mar 2017 18:10:47 +0200, Or Gerlitz wrote:
>> When dealing with ipv6 source tunnel key address attribute
>> (OVS_TUNNEL_KEY_ATTR_IPV6_SRC) we are wrongly setting the tunnel
>> dst ip, fix that.
>>
>> Fixes: 6b26ba3a7d95 ('openvswitch: netlink attributes for IPv6 tunneling')
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>> Reported-by: Paul Blakey <paulb@mellanox.com>
>
> Acked-by: Jiri Benc <jbenc@redhat.com>

Thanks, good spotting.

Acked-by: Joe Stringer <joe@ovn.org>
