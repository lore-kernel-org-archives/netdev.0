From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next] net: inet: diag: expose the socket mark to
 privileged processes.
Date: Thu, 8 Sep 2016 00:47:07 +0900
Message-ID: <CAKD1Yr3maNjdxzD4KqvqYjR2MMXFUdB41kt0Y6bs_9kV+vFt5w@mail.gmail.com>
References: <1473240756-101966-1-git-send-email-lorenzo@google.com> <201609071915.KyheN4G0%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Erik Kline <ek@google.com>, Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:38423 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756407AbcIGPr3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 11:47:29 -0400
Received: by mail-it0-f41.google.com with SMTP id c198so29221802ith.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 08:47:29 -0700 (PDT)
In-Reply-To: <201609071915.KyheN4G0%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 7, 2016 at 8:20 PM, kbuild test robot <lkp@intel.com> wrote:
> [auto build test ERROR on net-next/master]
>
>    net/sctp/sctp_diag.c: In function 'inet_sctp_diag_fill':
> >> net/sctp/sctp_diag.c:136:6: error: too few arguments to function 'inet_diag_msg_attrs_fill'
>      if (inet_diag_msg_attrs_fill(sk, skb, r, ext, user_ns))
>          ^~~~~~~~~~~~~~~~~~~~~~~~

Fixed in v3, and unit tests updated with basic SCTP tests as well.
