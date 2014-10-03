From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers:ethernet:davinci_emac.c:Fixes flaw in mac
 address handling.
Date: Fri, 03 Oct 2014 14:55:24 -0700 (PDT)
Message-ID: <20141003.145524.270976129977723195.davem@davemloft.net>
References: <1412217125-11057-1-git-send-email-mwelling@ieee.org>
	<20141003.130305.2216770567363258603.davem@davemloft.net>
	<20141003204359.GA10110@sysresccd>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mwelling@ieee.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141003204359.GA10110@sysresccd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Welling <mwelling@ieee.org>
Date: Fri, 3 Oct 2014 15:43:59 -0500

> On Fri, Oct 03, 2014 at 01:03:05PM -0700, David Miller wrote:
>> From: Michael Welling <mwelling@ieee.org>
>> Date: Wed,  1 Oct 2014 21:32:05 -0500
>> 
>> > The code currently checks the mac_addr variable that is clearly
>> > zero'd out during allocation.
>> > 
>> > Further code is added to bring the mac_addr from the partial pdata.
>> > 
>> > Signed-off-by: Michael Welling <mwelling@ieee.org>
>> 
>> I don't see anyone specifying a MAC address in the partial pdata,
>> so better to just delete that field.
>> 
>> Even if people did, I am not so sure that the partial pdata should
>> unconditionally trump an OF provided MAC address.
> 
> So should I just leave the code for handling the mac_addr field from the
> partial pdata out or make it such that the mac_addr field is overriden 
> if specified from the devicetree?

I'm saying the partial pdata mac_addr is completely unused and should
be removed.
