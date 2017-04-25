From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] IB/IPoIB: Check the headroom size
Date: Tue, 25 Apr 2017 17:39:12 +0300
Message-ID: <CAJ3xEMgwS1Bq8+eZC1iAr6xi8ZPHrchsOJ5r4LNJxR8P+6VipA@mail.gmail.com>
References: <1493114155-12101-1-git-send-email-honli@redhat.com>
 <CAJ3xEMg4_2ph7QwPsUb-tX-K4d2ppkqz98sPzytsmBCK=29WHw@mail.gmail.com>
 <CAAk-MO8O19iC2Yn-BMn5pKTAYxaSzGPMyta=fwes3XSvzmz_cQ@mail.gmail.com>
 <CAJ3xEMgw=9sj3rdahPEiST_yDfDJPNSZZLRn43tnb3bK4_RPzg@mail.gmail.com> <CAAk-MO-B8Liv6RyGye_Fx-9OELCUrGMj5SwK9UsciC=khSO5fA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Honggang LI <honli@redhat.com>, Erez Shitrit <erezsh@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Erez Shitrit <erezsh@dev.mellanox.co.il>,
        Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33694 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948109AbdDYOjN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 10:39:13 -0400
In-Reply-To: <CAAk-MO-B8Liv6RyGye_Fx-9OELCUrGMj5SwK9UsciC=khSO5fA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 2:43 PM, Erez Shitrit <erezsh@dev.mellanox.co.il> wrote:
> On Tue, Apr 25, 2017 at 2:14 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:

>> thanks for the info. Is this bug there since ipoib/bonding day one (and hence my bug...)
>> or was indeed introduced later? if later, can you explain how
>> fc791b633515 introduced that or you only know it by bisection?

> commit "fc791b633515" changes the size of the dev_hardlen to be 24 and
> required 24 extra bytes in the skb, before it was only 4, if skb is
> aligned to eth "mode" it already has 14 bytes for hard-header.
> So only after that commit we have the issue.

If got you right, Paolo's commit introduced a regression, so we (I
guess you and
Paolo) need to either solve it or we (community) should consider a
revert, please suggest.

The bug is now in stable and distro kernels, so please act.

Or.
