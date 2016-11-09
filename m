From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv4: ip_send_unicast_reply should set oif only if
 it is L3 master
Date: Wed, 9 Nov 2016 08:52:49 -0700
Message-ID: <b658cac5-34ab-ac96-4e38-802fa40a3f66@cumulusnetworks.com>
References: <1478645431-7454-1-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr3v8qYn0eRwJttBr_1KpPBLrPbDLp0+WanQSBKDkD6+0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:33411 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932904AbcKIPw4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 10:52:56 -0500
Received: by mail-it0-f54.google.com with SMTP id e187so41770895itc.0
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 07:52:56 -0800 (PST)
In-Reply-To: <CAKD1Yr3v8qYn0eRwJttBr_1KpPBLrPbDLp0+WanQSBKDkD6+0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/8/16 11:38 PM, Lorenzo Colitti wrote:
> On Wed, Nov 9, 2016 at 7:50 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> @@ -1577,7 +1577,8 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
> 
> Tested-by: Lorenzo Colitti <lorenzo@google.com>
> 
> This fixes the IPv4 test, thanks. I notice that 4.8 didn't have
> e0d56fdd73, so if this patch can get into 4.9 then there will be no
> release that had the behaviour change. Not sure if that's possible any
> more though.

This patch is for net so 4.9.

> 
> Can you also fix tcp_v6_send_response, which suffers from the same
> problem? Perhaps revert this hunk of e0d56fdd73 ("net: l3mdev: remove
> redundant calls"):
> 

Let me add it to this patch and re-send.
