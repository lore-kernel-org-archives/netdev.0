From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 7/7] nfp: flower vxlan neighbour keep-alive
Date: Mon, 25 Sep 2017 21:32:12 +0300
Message-ID: <CAJ3xEMgK-hqB-uRM4aom1gMsXxpx_o2uSpSj5_dFsT13-oDGAQ@mail.gmail.com>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com> <1506335021-32024-8-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:54114 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965518AbdIYScN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 14:32:13 -0400
Received: by mail-oi0-f52.google.com with SMTP id j126so8313759oia.10
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 11:32:13 -0700 (PDT)
In-Reply-To: <1506335021-32024-8-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 1:23 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> From: John Hurley <john.hurley@netronome.com>
>
> Periodically receive messages containing the destination IPs of tunnels
> that have recently forwarded traffic. Update the neighbour entries 'used'
> value for these IPs next hop.

Are you proactively sending keep alive messages from the driver or the
fw? what's wrong with the probes sent by the kernel NUD subsystem?

In our driver we also update the used value for neighs of offloaded
tunnels, we do it based on flow counters for the offloaded tunnels
which is an evidence for activity. Any reason for you not to apply a
similar practice?

Or.
