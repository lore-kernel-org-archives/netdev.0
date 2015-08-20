From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 5/9] geneve: Add support to collect tunnel metadata.
Date: Thu, 20 Aug 2015 13:33:46 -0700
Message-ID: <CALnjE+pvWd+MZinJU6kMVLnz0c2jemK8aWG2g9p+pKbMt2bgRQ@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
	<1439845905-31666-6-git-send-email-pshelar@nicira.com>
	<20150818.141232.155283851688115226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:38671 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbbHTUdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 16:33:47 -0400
Received: by igfj19 with SMTP id j19so447igf.1
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 13:33:47 -0700 (PDT)
In-Reply-To: <20150818.141232.155283851688115226.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 18, 2015 at 2:12 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Mon, 17 Aug 2015 14:11:41 -0700
>
>> +     if (tun_dst)
>> +             skb_dst_set(skb, (struct dst_entry *)tun_dst);
>> +
>
> Please don't cast things like this, it is completely unnecessary:
>
>         skb_dst_set(skb, &tun_dst->dst);

ok.
