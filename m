From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH v4 net-next 09/10] openvswitch: Add force commit.
Date: Thu, 9 Feb 2017 13:45:08 -0800
Message-ID: <CAPWQB7FQ=yr1MP_PcqRtewb5S9SoYr_3H9UmSjFfi+3c04fP-w@mail.gmail.com>
References: <1486668121-45709-1-git-send-email-jarno@ovn.org> <1486668121-45709-10-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        pravin shelar <pshelar@ovn.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:56158 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932106AbdBIVpe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 16:45:34 -0500
Received: from mfilter11-d.gandi.net (mfilter11-d.gandi.net [217.70.178.131])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id CDF1CA80D8
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:45:31 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter11-d.gandi.net (mfilter11-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 9KWzfhVrERqu for <netdev@vger.kernel.org>;
        Thu,  9 Feb 2017 22:45:30 +0100 (CET)
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
        (Authenticated sender: joe@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 4C795A80BE
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:45:30 +0100 (CET)
Received: by mail-qk0-f179.google.com with SMTP id s140so19752850qke.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 13:45:30 -0800 (PST)
In-Reply-To: <1486668121-45709-10-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 February 2017 at 11:22, Jarno Rajahalme <jarno@ovn.org> wrote:
> Stateful network admission policy may allow connections to one
> direction and reject connections initiated in the other direction.
> After policy change it is possible that for a new connection an
> overlapping conntrack entry already exists, where the original
> direction of the existing connection is opposed to the new
> connection's initial packet.
>
> Most importantly, conntrack state relating to the current packet gets
> the "reply" designation based on whether the original direction tuple
> or the reply direction tuple matched.  If this "directionality" is
> wrong w.r.t. to the stateful network admission policy it may happen
> that packets in neither direction are correctly admitted.
>
> This patch adds a new "force commit" option to the OVS conntrack
> action that checks the original direction of an existing conntrack
> entry.  If that direction is opposed to the current packet, the
> existing conntrack entry is deleted and a new one is subsequently
> created in the correct direction.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> Acked-by: Pravin B Shelar <pshelar@ovn.org>

Acked-by: Joe Stringer <joe@ovn.org>
