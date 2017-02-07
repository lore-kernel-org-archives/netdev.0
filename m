From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next/iproute v2 0/5] tc: bash-completion: Add
 features
Date: Tue, 7 Feb 2017 11:54:31 -0800
Message-ID: <20170207115431.4bd9508f@xeon-e3>
References: <1486475452-39214-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eladr@mellanox.com, idosch@mellanox.com,
        jiri@mellanox.com, jhs@mojatatu.com, mrv@mojatatu.com
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33816 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753909AbdBGTzQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 14:55:16 -0500
Received: by mail-pg0-f44.google.com with SMTP id 14so41351058pgg.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 11:54:38 -0800 (PST)
In-Reply-To: <1486475452-39214-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  7 Feb 2017 15:50:47 +0200
Yotam Gigi <yotamg@mellanox.com> wrote:

> The first 4 patches add support for autompletion of filter actions, thus
> allowing the following tab completions:
> 
> $ tc filter add dev eth0 u32 [...] action <TAB>
> bpf     gact    mirred  sample
> 
> $ tc filter add dev eth0 u32 [...] action sample <TAB>
> action  group   rate    trunc
> 
> $ tc filter add dev eth0 u32 [...] \
> 	action sample group 10 rate 10 action mirred <TAB>
> action    dev       egress    index     ingress   mirror    redirect
> 
> Finally, the last patch adds support in matchall autocompletion.
> 
> v1->v2:
>  - Rebased on top of net-next tree
> 
> Yotam Gigi (5):
>   tc: bash-completion: Add the _from variant to _tc_one* funcs
>   tc: bash-completion: Prepare action autocomplete to support several
>     actions
>   tc: bash-completion: Make the *_KIND variables global
>   tc: bash-completion: Add support for filter actions
>   tc: bash-completion: Add support for matchall
> 
>  bash-completion/tc | 121 ++++++++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 96 insertions(+), 25 deletions(-)
> 

Applied to net-next
