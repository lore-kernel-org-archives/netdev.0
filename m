From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: Re: [PATCH net-next] ipv6: Initial skb->dev and skb->protocol in
 ip6_output
Date: Fri, 9 Jun 2017 12:45:01 -0700
Message-ID: <9999fb16-74c0-1f7a-7657-5905fcc0db63@gmail.com>
References: <1497035168-9093-1-git-send-email-chenbofeng.kernel@gmail.com>
 <20170609.150836.1427149901008136163.davem@davemloft.net>
 <3270a030-2608-1629-07d6-7fdeee9e98cc@gmail.com>
 <87d1adge1i.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        lorenzo@google.com, edumazet@google.com, fengc@google.com
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32894 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751584AbdFITpD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 15:45:03 -0400
Received: by mail-pf0-f178.google.com with SMTP id 83so31637455pfr.0
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 12:45:03 -0700 (PDT)
In-Reply-To: <87d1adge1i.fsf@miraculix.mork.no>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/09/2017 12:24 PM, Bjørn Mork wrote:
> Chenbo Feng <chenbofeng.kernel@gmail.com> writes:
>
>> This patch is still under working since it may have problem with
>> ip_fragment() call, did you applied it already? Should I send a revert
>> patch to you then?
> It does? I initially thought so too, but looking closer I believe the
> ip6_copy_metadata() calls in ip6_fragment() takes care of it.
>
>
>
> Bjørn
>
At least in the fail_toobig code path of ip_fragment() call, skb->dev 
get assigned again. It seems to be redundant with this patch or it will 
rewrite the skb->dev field. I will revert this one and upload again 
after I have a proper handle for that.
