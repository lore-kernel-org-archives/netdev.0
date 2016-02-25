From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/5] introduce IFE action
Date: Thu, 25 Feb 2016 17:46:51 -0500
Message-ID: <56CF845B.7040607@mojatatu.com>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com>
 <1456231760-2513-2-git-send-email-jhs@emojatatu.com>
 <56CDEA6D.1000908@iogearbox.net> <56CEF1A8.3020505@mojatatu.com>
 <56CF7640.2060202@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	dj@verizon.com
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:33300 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbcBYWqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 17:46:53 -0500
Received: by mail-ig0-f195.google.com with SMTP id hb3so2293531igb.0
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 14:46:53 -0800 (PST)
In-Reply-To: <56CF7640.2060202@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-25 04:46 PM, Daniel Borkmann wrote:
> On 02/25/2016 01:20 PM, Jamal Hadi Salim wrote:

>> Let me think about it. Likely it will be subsequent patches - I just
>> want to get this set out first.
>
> Yes, I mean one of the key motivation was "[...] to horizontally scale
> packet processing at scope of a chasis or rack [...]".


By adding more processing points horizontally. Please read the paper;
I think we are getting to a point where this discussion is no longer
productive.

> So for people
> who don't have that NIC with embedded Cavium processor, they might
> already hit scalability issues for encode/decode right there.
>

A lock on a policy that already matches is not a serious
scaling problem that you need to offload to an embedded NIC.
Do note the point here is to scale by adding more machines.
And this shit is deployed and has proven it does scale.

cheers,
jamal
