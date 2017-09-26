From: John Hurley <john.hurley@netronome.com>
Subject: Re: [PATCH net-next 7/7] nfp: flower vxlan neighbour keep-alive
Date: Tue, 26 Sep 2017 10:37:53 +0100
Message-ID: <CAK+XE=nfndmKbgz174CEKzfBHbf7nTBX9CUb47MPBnDssJJ0fA@mail.gmail.com>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
 <1506335021-32024-8-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgK-hqB-uRM4aom1gMsXxpx_o2uSpSj5_dFsT13-oDGAQ@mail.gmail.com> <CAK+XE=mVKbAqYwSYvLb0y48O9D-Oq+B_bks7c9iwjsm0j7oYvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:44986 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965142AbdIZJhz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 05:37:55 -0400
Received: by mail-wm0-f43.google.com with SMTP id m127so14764573wmm.1
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 02:37:54 -0700 (PDT)
In-Reply-To: <CAK+XE=mVKbAqYwSYvLb0y48O9D-Oq+B_bks7c9iwjsm0j7oYvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Reposting in plantext only]



On Mon, Sep 25, 2017 at 7:32 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>
> On Mon, Sep 25, 2017 at 1:23 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > From: John Hurley <john.hurley@netronome.com>
> >
> > Periodically receive messages containing the destination IPs of tunnels
> > that have recently forwarded traffic. Update the neighbour entries 'used'
> > value for these IPs next hop.
>
> Are you proactively sending keep alive messages from the driver or the
> fw? what's wrong with the probes sent by the kernel NUD subsystem?
>

Hi Or,

The messages are sent from the FW to the driver. They indicate which
offloaded tunnels are currently active.

>
> In our driver we also update the used value for neighs of offloaded
> tunnels, we do it based on flow counters for the offloaded tunnels
> which is an evidence for activity. Any reason for you not to apply a
> similar practice?


Yes, this would provide the same outcome. Because our firmware already
offered these messages, we chose to support this approach.

>
>
> Or.
