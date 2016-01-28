From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v4 net-next] ravb: Add dma queue interrupt support
Date: Thu, 28 Jan 2016 18:50:29 +0300
Message-ID: <56AA38C5.6070004@cogentembedded.com>
References: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
 <20160126002300.GA27856@verge.net.au> <56A7C252.3040707@cogentembedded.com>
 <20160127014944.GD27499@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35216 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966653AbcA1Pud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 10:50:33 -0500
Received: by mail-lf0-f43.google.com with SMTP id c192so29571704lfe.2
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 07:50:32 -0800 (PST)
In-Reply-To: <20160127014944.GD27499@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/27/2016 04:49 AM, Simon Horman wrote:

>>>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

    Kaneko-san, with the amount of the review changes, it might make sense for 
you to assume the authorship of this patch, only noting it's based on 
Mizuguchi-san's work. In principle, when you change the original patch, you 
should document the changes you made in the change log, above ---...

>>>> This patch supports the following interrupts.
>>>>
>>>> - One interrupt for multiple (descriptor, error, management)
>>>> - One interrupt for emac
>>>> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
>>>>
>>>> This patch improve efficiency of the interrupt handler by adding the
>>>> interrupt handler corresponding to each interrupt source described
>>>> above. Additionally, it reduces the number of times of the access to
>>>> EthernetAVB IF.
>>>>
>>>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>>>
>>> I have tested this patch and the result seems positive.
>>
>>     Tested on gen3 only I guess?
>
> Yes, that is correct.
>
>>> Please let me know if any more/different testing would help.
>>
>>     Sanity testing on some gen2 SoC wouldn't hurt (if you have time).
>
> I don't believe that I have access to a gen2 board (+ extra hardware ?)
> where ravb works.

    Sorry, I just forgot about that.

> If you do would it be possible for you to do a sanity test?

    Yes, of course.

MBR, Sergei
