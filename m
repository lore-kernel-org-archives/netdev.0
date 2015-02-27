From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: simplify __bcmgenet_tx_reclaim()
Date: Fri, 27 Feb 2015 15:42:47 -0800
Message-ID: <54F100F7.7000709@gmail.com>
References: <20150225185500.C7EBC2211C6@puck.mtv.corp.google.com>	 <54F0ED2A.9040306@gmail.com> <1425080378.5130.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Jaedon Shin <jaedon.shin@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36420 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191AbbB0XnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 18:43:11 -0500
Received: by padfb1 with SMTP id fb1so525512pad.3
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 15:43:11 -0800 (PST)
In-Reply-To: <1425080378.5130.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/02/15 15:39, Eric Dumazet wrote:
> On Fri, 2015-02-27 at 14:18 -0800, Florian Fainelli wrote:
>> On 25/02/15 10:55, Petri Gynther wrote:
> 
>> Nice cleanups!
>>
>>>
>>> Signed-off-by: Petri Gynther <pgynther@google.com>
>>
>> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Is any one working adding BQL & xmit_more on this driver ?

I have this on my todo, but I would need Jaedon's patch which move tx
completion to NAPI before submitting these.
-- 
Florian
