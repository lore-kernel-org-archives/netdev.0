From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next v3 3/9] ipv4: fib_rules: Dump FIB rules when
 registering FIB notifier
Date: Thu, 16 Mar 2017 09:18:33 -0600
Message-ID: <7471aa48-c06a-6984-bc8d-03abf7bfa487@cumulusnetworks.com>
References: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
 <1489651700-3586-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        shm@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, lorenzo@google.com,
        mateusz.bajorski@nokia.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:36583 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752066AbdCPPTy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 11:19:54 -0400
Received: by mail-it0-f47.google.com with SMTP id w124so74403290itb.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 08:19:53 -0700 (PDT)
In-Reply-To: <1489651700-3586-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/16/17 2:08 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> In commit c3852ef7f2f8 ("ipv4: fib: Replay events when registering FIB
> notifier") we dumped the FIB tables and replayed the events to the
> passed notification block.
> 
> However, we merely sent a RULE_ADD notification in case custom rules
> were in use. As explained in previous patches, this approach won't work
> anymore. Instead, we should notify the caller about all the FIB rules
> and let it act accordingly.
> 
> Upon registration to the FIB notification chain, replay a RULE_ADD
> notification for each programmed FIB rule, custom or not. The integrity
> of the dump is ensured by the mechanism introduced in the above
> mentioned commit.
> 
> Prevent regressions by making sure current listeners correctly sanitize
> the notified rules.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 13 ++++++++++++-
>  drivers/net/ethernet/rocker/rocker_main.c             | 17 +++++++++++++++--
>  net/ipv4/fib_rules.c                                  | 19 ++++++++++++++++---
>  3 files changed, 43 insertions(+), 6 deletions(-)

Acked-by: David Ahern <dsa@cumulusnetworks.com>
