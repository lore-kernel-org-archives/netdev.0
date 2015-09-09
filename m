From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: dsa: bcm_sf2: Fix 64-bits register writes
Date: Tue, 8 Sep 2015 23:33:24 -0400
Message-ID: <20150909033323.GA25536@ketchup>
References: <1441768001-25318-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:50663
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752829AbbIIDd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 23:33:29 -0400
Content-Disposition: inline
In-Reply-To: <1441768001-25318-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sep. Tuesday 08 (37) 08:06 PM, Florian Fainelli wrote:
> The macro to write 64-bits quantities to the 32-bits register swapped
> the value and offsets arguments, we want to preserve the ordering of the
> arguments with respect to how writel() is implemented for instance:
> value first, offset/base second.
> 
> Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
