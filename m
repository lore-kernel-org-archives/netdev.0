From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: bcmgenet: Software reset EPHY after power on
Date: Tue, 03 Nov 2015 15:44:14 -0800
Message-ID: <563946CE.8070706@gmail.com>
References: <1446167495-3923-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32938 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641AbbKCXpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 18:45:00 -0500
Received: by pabfh17 with SMTP id fh17so32461894pab.0
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 15:45:00 -0800 (PST)
In-Reply-To: <1446167495-3923-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/10/15 18:11, Florian Fainelli wrote:
> The EPHY on GENET v1->v3 is extremely finicky, and will show occasional
> failures based on the timing and reset sequence, ranging from duplicate
> packets, to extremely high latencies.
> 
> Perform an additional software reset, and re-configuration to make sure it is
> in a consistent and working state.
> 
> Fixes: 6ac3ce8295e6 ("net: bcmgenet: Remove excessive PHY reset")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

I see that you have applied this to your pull request sent to Linus
today, could you also queue this for 4.3-stable? Thank you!
-- 
Florian
