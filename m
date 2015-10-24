From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv2 net 1/3] openvswitch: Fix double-free on ip_defrag() errors
Date: Sat, 24 Oct 2015 11:43:16 -0700
Message-ID: <CANr6G5wZ5DKmgpEmkaL2ytUuUbZoye_0XSE6UK1KOfKYDD--=Q@mail.gmail.com>
References: <1445643135-65034-1-git-send-email-joestringer@nicira.com> <20151024082025.GB19055@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Andy Zhou <azhou@nicira.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:32859 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbbJXSng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 14:43:36 -0400
Received: by yknn9 with SMTP id n9so149802389ykn.0
        for <netdev@vger.kernel.org>; Sat, 24 Oct 2015 11:43:35 -0700 (PDT)
In-Reply-To: <20151024082025.GB19055@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24 October 2015 at 01:20, Florian Westphal <fw@strlen.de> wrote:
> Joe Stringer <joestringer@nicira.com> wrote:
>>  err:
>> +     if (err)
>> +             kfree_skb(skb);
>>       skb_push(skb, nh_ofs);
>
> That looks... wrong :-}

D'oh. Teaches me for last minute adjustments. I'll resend.
