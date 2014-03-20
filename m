From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] micrel: fix masking off LED bits
Date: Thu, 20 Mar 2014 21:44:05 +0300
Message-ID: <532B36F5.20605@cogentembedded.com>
References: <201403190258.16812.sergei.shtylyov@cogentembedded.com> <20140319.174205.1425627653050633421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	ben.dooks@codethink.co.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:41565 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbaCTRoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 13:44:11 -0400
Received: by mail-lb0-f176.google.com with SMTP id 10so870142lbg.35
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 10:44:10 -0700 (PDT)
In-Reply-To: <20140319.174205.1425627653050633421.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/20/2014 12:42 AM, David Miller wrote:

>> Commit 20d8435a1cff (phy: micrel: add of configuration for LED mode) made the
>> obvious mistake when masking off  the LED mode bits: forgot to do a logical NOT
>> to the mask with which it ANDs the register value, so that unrelated bits are
>> cleared instead.

    I'm seeing now that I hadn't finished editing the changelog before 
submitting -- the verbs have inconsistent times. So much for my haste... :-)

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> Applied to net-next, thanks.

    Thanks.

WBR, Sergei
