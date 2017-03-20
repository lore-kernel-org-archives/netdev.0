From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH nf v2 1/1] netfilter: snmp: Fix one possible panic when
 snmp_trap_helper fail to register
Date: Mon, 20 Mar 2017 13:09:00 +0300
Message-ID: <02f61fe0-37d9-8837-1c8f-390c5dea6ff4@cogentembedded.com>
References: <1490003728-33866-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: fgao@ikuai8.com, pablo@netfilter.org, davem@davemloft.net,
        jolsa@redhat.com, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:32829 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753962AbdCTKJ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 06:09:28 -0400
Received: by mail-lf0-f54.google.com with SMTP id a6so53259500lfa.0
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 03:09:02 -0700 (PDT)
In-Reply-To: <1490003728-33866-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/20/2017 12:55 PM, fgao@ikuai8.com wrote:

> From: Gao Feng <fgao@ikuai8.com>
>
> In the commit <93557f53e1fb> ("netfilter: nf_conntrack: nf_conntrack snmp

    Angle brackets not needed. :-)
    The commit citing style is the same as for the Fixes: tag.

> helper"), the snmp_helper is replaced by nf_nat_snmp_hook. So the
> snmp_helper is never registered. But it still tries to unregister the
> snmp_helper, it could cause the panic.
>
> Now remove the useless snmp_helper and the unregister call in the
> error handler.
>
> Fixes: 93557f53e1fb ("netfilter: nf_conntrack: nf_conntrack snmp helper")
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
[...]

MBR, Sergei
