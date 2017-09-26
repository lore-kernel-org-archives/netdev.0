From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 0/7] nfp: flower vxlan tunnel offload
Date: Tue, 26 Sep 2017 17:17:02 +0300
Message-ID: <CAJ3xEMjOkF7vKHY=+q1dHXGdsyEXFPUa6dsGD_-M3+TX=DNouA@mail.gmail.com>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgfRuD2Y-P2eTKmXpciiopA8js4zbO_nNOA6J62sn--mw@mail.gmail.com>
 <20170925170451.GD18763@vergenet.net> <20170926121509.50a32571@griffin>
 <CAJ3xEMjEAhzC5=S7-dx8RiS=E7gYBBrtWY=9Cvqj-K3kyT9o3A@mail.gmail.com> <20170926145143.28bf52bd@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Paul Blakey <paulb@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34067 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965237AbdIZORD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 10:17:03 -0400
Received: by mail-oi0-f65.google.com with SMTP id v188so6268117oia.1
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 07:17:03 -0700 (PDT)
In-Reply-To: <20170926145143.28bf52bd@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 3:51 PM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 26 Sep 2017 15:41:37 +0300, Or Gerlitz wrote:
>> Please note that the way the rule is being set to the HW driver is by delegation
>> done in flower, see these commits (specifically "Add offload support
>> using egress Hardware device")
>
> It's very well possible the bug is somewhere in net/sched.

maybe before/instead you call it a bug, take a look on the design
there and maybe
tell us how to possibly do that otherwise?
