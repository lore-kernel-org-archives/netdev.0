From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.1[78] page allocation failure. order:3, mode:0x20
Date: Sat, 23 Sep 2006 13:03:22 -0700 (PDT)
Message-ID: <20060923.130322.78711694.davem@davemloft.net>
References: <20060922.222507.74751476.davem@davemloft.net>
	<20060922223348.1b24fda5.akpm@osdl.org>
	<451581FA.5080403@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, Holger.Kiehl@dwd.de, linux-kernel@vger.kernel.org,
	linux-net@vger.kernel.org, netdev@vger.kernel.org,
	john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:24271
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751517AbWIWUDT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 16:03:19 -0400
To: auke-jan.h.kok@intel.com
In-Reply-To: <451581FA.5080403@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Sat, 23 Sep 2006 11:50:34 -0700

> Andrew Morton wrote:
> > It's still there, isn't it?
> > 
> > For the 9k MTU case, for example, we end up allocating 16384 byte skbs
> > instead of 32786 kbytes ones.
> 
> yes, the only thing I'm doing is accounting for the 2 bytes one steap earlier. 

Ok, I'm fine with this patch unless it causes some regression that hasn't
been discovered yet :-)
