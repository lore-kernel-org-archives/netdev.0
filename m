From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v4 net-next 3/4] net/sched: tc_mirred: Rename public
 predicates 'is_tcf_mirred_redirect' and 'is_tcf_mirred_mirror'
Date: Thu, 13 Oct 2016 07:57:06 -0400
Message-ID: <e602a620-d4f9-6788-eca4-a666966a9448@mojatatu.com>
References: <1476338804-25440-1-git-send-email-shmulik.ladkani@gmail.com>
 <1476338804-25440-4-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Hariprasad S <hariprasad@chelsio.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35844 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754728AbcJMMJC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 08:09:02 -0400
Received: by mail-io0-f193.google.com with SMTP id o141so4773168ioe.3
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 05:09:02 -0700 (PDT)
In-Reply-To: <1476338804-25440-4-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-13 02:06 AM, Shmulik Ladkani wrote:
> These accessors are used in various drivers that support tc offloading,
> to detect properties of a given 'tc_action'.
>
> 'is_tcf_mirred_redirect' tests that the action is TCA_EGRESS_REDIR.
> 'is_tcf_mirred_mirror' tests that the action is TCA_EGRESS_MIRROR.
>
> As a prep towards supporting INGRESS redir/mirror, rename these
> predicates to reflect their true meaning:
>   s/is_tcf_mirred_redirect/is_tcf_mirred_egress_redirect/
>   s/is_tcf_mirred_mirror/is_tcf_mirred_egress_mirror/
>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
