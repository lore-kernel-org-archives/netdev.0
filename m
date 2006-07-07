From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] tg3: add amd8131 to "write reorder" chipsets
Date: Fri, 07 Jul 2006 13:21:38 -0700
Message-ID: <44AEC252.70209@intel.com>
References: <20060707185831.GC22636@tuxdriver.com> <20060707.121220.99179918.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48707 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751243AbWGGUa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 16:30:27 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060707.121220.99179918.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Fri, 7 Jul 2006 14:58:36 -0400
> 
>> Add the AMD 8131 bridge to the list of chipsets that reorder writes.
>>
>> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> 
> What failure report is this chipset blacklist addition based
> upon?  I just want to look at the paper trail before adding
> this.

Moreover, since e1000 suffers from reordering/write-combining problems on the 
8132, I'm starting to see an (ugly) pattern here. I didn't know that tg3 has a 
whole blacklist for this, could this affect other network cards as well?

Auke
