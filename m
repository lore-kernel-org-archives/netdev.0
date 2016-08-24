From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] phy: request shared IRQ
Date: Wed, 24 Aug 2016 21:41:07 +0300
Message-ID: <e2248086-6087-0fcd-1338-8f6463943c62@cogentembedded.com>
References: <1472061216-11111-1-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        brad.mouring@ni.com, Nathan Sullivan <nathan.sullivan@ni.com>
To: Xander Huff <xander.huff@ni.com>, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:33108 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754464AbcHXSrH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 14:47:07 -0400
Received: by mail-lf0-f54.google.com with SMTP id b199so18484560lfe.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 11:47:06 -0700 (PDT)
In-Reply-To: <1472061216-11111-1-git-send-email-xander.huff@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/24/2016 08:53 PM, Xander Huff wrote:

> From: Nathan Sullivan <nathan.sullivan@ni.com>
>
> On hardware with multiple PHY devices hooked up to the same IRQ line, allow
> them to share it.

    Note that it had been allowed until my (erroneous?) commit 
33c133cc7598e60976a069344910d63e56cc4401 ("phy: IRQ cannot be shared"), so I'd 
like this commit just reverted instead...
    I'm not sure now what was the reason I concluded that the IRQ sharing was 
impossible... most probably I thought that the kernel IRQ handling code exited 
the loop over the IRQ actions once IRQ_HANDLED was returned -- which is 
obviously not so in reality...

> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> Signed-off-by: Xander Huff <xander.huff@ni.com>
> Acked-by: Ben Shelton <ben.shelton@ni.com>
> Acked-by: Jaeden Amero <jaeden.amero@ni.com>
[...]

MBR, Sergei
