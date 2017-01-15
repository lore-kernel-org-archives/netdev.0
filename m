From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: Re: [PATCH net-next] IPsec: do not ignore crypto err in ah input
Date: Sun, 15 Jan 2017 08:06:23 +0200
Message-ID: <CAOtvUMfa2Z_NSO3s5d0Vnr6WiJotv1SDR1nLqtObDv-WaDCaPw@mail.gmail.com>
References: <1484228002-25078-1-git-send-email-gilad@benyossef.com> <20170113074551.GA24287@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: steffen.klassert@secunet.com,
        Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Ofir Drang <ofir.drang@arm.com>, gilad.benyossef@arm.com
To: Alexander Alemayhu <alexander@alemayhu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36095 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750824AbdAOGGZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 01:06:25 -0500
Received: by mail-io0-f177.google.com with SMTP id j13so71914644iod.3
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 22:06:24 -0800 (PST)
In-Reply-To: <20170113074551.GA24287@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 9:45 AM, Alexander Alemayhu
<alexander@alemayhu.com> wrote:
> On Thu, Jan 12, 2017 at 03:33:22PM +0200, Gilad Ben-Yossef wrote:
>> ah input processing uses the asynchrnous hash crypto API which
>> supplies an error code as part of the operation completion but
>> the error code was being ignored.
>>
> s/asynchrnous/asynchronous

Yes, I have missed that.

Thank you for your review. I will send a fixed version.

Thanks,
Gilad

-- 
Gilad Ben-Yossef
Chief Coffee Drinker

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru
