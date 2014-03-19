From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] micrel: fix masking off LED bits
Date: Wed, 19 Mar 2014 22:35:30 +0300
Message-ID: <5329F182.6090206@cogentembedded.com>
References: <201403190258.16812.sergei.shtylyov@cogentembedded.com> <53295171.3020700@codethink.co.uk> <CAGVrzcZd6rx0dbAdtqk3pbjuTVr4vwFqsRJxgc+dTQ0imnY57Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:52196 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbaCSSfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 14:35:34 -0400
Received: by mail-lb0-f182.google.com with SMTP id n15so6365949lbi.27
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 11:35:32 -0700 (PDT)
In-Reply-To: <CAGVrzcZd6rx0dbAdtqk3pbjuTVr4vwFqsRJxgc+dTQ0imnY57Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/19/2014 07:21 PM, Florian Fainelli wrote:

>>> Commit 20d8435a1cff (phy: micrel: add of configuration for LED mode) made
>>> the
>>> obvious mistake when masking off  the LED mode bits: forgot to do a
>>> logical NOT
>>> to the mask with which it ANDs the register value, so that unrelated bits
>>> are
>>> cleared instead.

>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>> Acked-by: Ben Dooks <ben.dooks@codethink.co.uk>

> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

    Oh, sorry for not CCing you -- I forgot that phylib is now maintained.

WBR, Sergei
