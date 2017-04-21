From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH netnext 0/3] packet: Add option to create new fanout group
 with unique id.
Date: Fri, 21 Apr 2017 10:59:31 -0400
Message-ID: <CAF=yD-J_tROiJv9eHsir+YYyZTKpXBueGecpGxbR8vkSqeSn=w@mail.gmail.com>
References: <20170420192546.5567-1-maloneykernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Mike Maloney <maloney@google.com>
To: Mike Maloney <maloneykernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35747 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162276AbdDUSJr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:09:47 -0400
Received: by mail-qt0-f193.google.com with SMTP id o36so12869725qtb.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:09:47 -0700 (PDT)
In-Reply-To: <20170420192546.5567-1-maloneykernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 3:25 PM, Mike Maloney <maloneykernel@gmail.com> wrote:
> From: Mike Maloney <maloney@google.com>
>
> Fanout uses a per net global namespace. A process that intends to create a
> new fanout group can accidentally join an existing group. It is
> not possible to detect this.
>
> Add a socket option to specify on the first call to
> setsockopt(..., PACKET_FANOUT, ...) to ensure that a new group is created.
> Also add tests.
>
> Mike Maloney (3):
>   selftests/net: cleanup unused parameter in psock_fanout
>   packet: add PACKET_FANOUT_FLAG_UNIQUEID to assign new fanout group id.
>   selftests/net: add tests for PACKET_FANOUT_FLAG_UNIQUEID
>
>  include/uapi/linux/if_packet.h             |  1 +
>  net/packet/af_packet.c                     | 44 ++++++++++++++
>  tools/testing/selftests/net/psock_fanout.c | 93 ++++++++++++++++++++++++++----
>  3 files changed, 128 insertions(+), 10 deletions(-)

Gmail refused to send out the main patch (2/3) from a fresh account. I
resubmitted the entire patchset on Mike's behalf.
