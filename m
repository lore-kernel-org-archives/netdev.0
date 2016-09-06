From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 1/2] fib: introduce fib notification
 infrastructure
Date: Tue, 6 Sep 2016 09:13:36 -0600
Message-ID: <e004cc9f-d9ac-3368-4045-db5a0f59347b@cumulusnetworks.com>
References: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
 <1473163300-2045-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, ast@plumgrid.com, edumazet@google.com,
        hannes@stressinduktion.org, f.fainelli@gmail.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@intel.com,
        andrew@lunn.ch, ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34526 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753186AbcIFPNi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 11:13:38 -0400
Received: by mail-pa0-f43.google.com with SMTP id to9so33586061pac.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 08:13:38 -0700 (PDT)
In-Reply-To: <1473163300-2045-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/6/16 6:01 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> This allows to pass information about added/deleted fib entries to
> whoever is interested. This is done in a very similar way as devinet
> notifies address additions/removals.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/ip_fib.h | 19 +++++++++++++++++++
>  net/ipv4/fib_trie.c  | 43 +++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 62 insertions(+)

Do you intend for this set of notifiers to work with policy routing (FIB rules) as well?
