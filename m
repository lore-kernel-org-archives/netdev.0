From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] sh_eth: use RNC mode for R8A7790/R87791
Date: Tue, 03 Jun 2014 00:55:38 +0400
Message-ID: <538CE4CA.4090301@cogentembedded.com>
References: <1401729456-23514-1-git-send-email-ben.dooks@codethink.co.uk>	<20140602.115303.1283021229124256917.davem@davemloft.net>	<538CD19B.5060208@cogentembedded.com> <20140602.134915.1162774321657125992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ben.dooks@codethink.co.uk, linux-kernel@codethink.co.uk,
	netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	magnus.damn@opensource.se, horms@verge.net.au,
	yoshihiro.shimoda.uh@renesas.com, cm-hiep@jinso.co.jp
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:63978 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196AbaFBUzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 16:55:36 -0400
Received: by mail-la0-f53.google.com with SMTP id ty20so2949248lab.12
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 13:55:35 -0700 (PDT)
In-Reply-To: <20140602.134915.1162774321657125992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2014 12:49 AM, David Miller wrote:

>>     Looks like the early SH2/3 SoCs didn't implement the whole register.
>> Despite that, sh_eth_dev_init() always writes to this register... :-/
>> So far, the RMCR.RNC bit was mostly set for the Gigabit-capable
>> controllers, however that rule wasn't strictly followed. Well, this
>> driver is still a mess, and it's hard to deal with it without the
>> necessary documentation.

> Why don't we therefore:

> 1) Skip the register write if the per-chip value is zero.

    I rather thought about not writing when the register is not implemented.
I'll probably look into this when I have time.

> 2) Add the RNC bit to all of the gigabit capable controllers.

    I probably misspoke -- all the Gigabit controllers already have it set, 
it's just that some 100 MBbps ones have it set, but most don't.

WBR, Sergei
