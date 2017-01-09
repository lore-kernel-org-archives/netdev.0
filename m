From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: dsa: Make dsa_switch_ops const
Date: Mon, 9 Jan 2017 11:39:10 -0800
Message-ID: <f0f7a1c1-3559-501a-f573-2a1797ba66cd@gmail.com>
References: <20170108225208.15431-1-f.fainelli@gmail.com>
 <20170109.143417.1830765753133219802.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35727 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763641AbdAITjR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:39:17 -0500
Received: by mail-pg0-f68.google.com with SMTP id 204so5671552pge.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 11:39:17 -0800 (PST)
In-Reply-To: <20170109.143417.1830765753133219802.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/2017 11:34 AM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Sun,  8 Jan 2017 14:52:04 -0800
> 
>> This patch series allows us to annotate dsa_switch_ops with a const
>> qualifier.
> 
> I kinda suspect this will have minor conflicts with the ops overwrite
> bug fix I applied to 'net' right?

That is correct.

> 
> I think I'll wait until I merge net into net-next before I try to
> apply this, and that should happend soon'ish.  I'm just waiting for
> Linus to take in my pull request.

Sure thing, thanks!
-- 
Florian
