From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers:ethernet:davinci_emac.c:Fixes flaw in mac
 address handling.
Date: Fri, 03 Oct 2014 13:03:05 -0700 (PDT)
Message-ID: <20141003.130305.2216770567363258603.davem@davemloft.net>
References: <1412217125-11057-1-git-send-email-mwelling@ieee.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mwelling@ieee.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412217125-11057-1-git-send-email-mwelling@ieee.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Welling <mwelling@ieee.org>
Date: Wed,  1 Oct 2014 21:32:05 -0500

> The code currently checks the mac_addr variable that is clearly
> zero'd out during allocation.
> 
> Further code is added to bring the mac_addr from the partial pdata.
> 
> Signed-off-by: Michael Welling <mwelling@ieee.org>

I don't see anyone specifying a MAC address in the partial pdata,
so better to just delete that field.

Even if people did, I am not so sure that the partial pdata should
unconditionally trump an OF provided MAC address.
