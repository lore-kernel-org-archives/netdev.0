From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2] skbuff: Fix skb checksum flag on skb pull
Date: Fri, 25 Sep 2015 19:48:57 -0700
Message-ID: <CALnjE+pyz_qTYXOm1vB89g+-KvE7dHfaaw5iG5manoYzLd7FHg@mail.gmail.com>
References: <1442951873-4803-1-git-send-email-pshelar@nicira.com>
	<20150924.140931.1967362456389755405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38808 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932109AbbIZCtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 22:49:00 -0400
Received: by igxx6 with SMTP id x6so20978314igx.1
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 19:48:58 -0700 (PDT)
In-Reply-To: <20150924.140931.1967362456389755405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 2:09 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Tue, 22 Sep 2015 12:57:53 -0700
>
>> VXLAN device can receive skb with checksum partial. But the checksum
>> offset could be in outer header which is pulled on receive. This results
>> in negative checksum offset for the skb. Such skb can cause the assert
>> failure in skb_checksum_help(). Following patch fixes the bug by setting
>> checksum-none while pulling outer header.
>>
>> Following is the kernel panic msg from old kernel hitting the bug.
>  ...
>> Reported-by: Anupam Chanda <achanda@vmware.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> Applied, thanks.

Thanks for applying it. Since I have seen this bug on older kernel can
you also queue it for -stable.
