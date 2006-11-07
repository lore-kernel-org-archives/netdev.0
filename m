From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] Rewrite e100_phys_id
Date: Tue, 07 Nov 2006 14:34:57 -0800
Message-ID: <45510A11.9070803@intel.com>
References: <20061026191154.GG5591@parisc-linux.org> <4550D16A.1090008@intel.com> <20061107190632.GW27140@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45643 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1753781AbWKGWfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 17:35:05 -0500
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20061107190632.GW27140@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Tue, Nov 07, 2006 at 10:33:14AM -0800, Auke Kok wrote:
>> Matthew Wilcox wrote:
>>> Tested on the internal interface of an HP Integrity rx2600.
>> bad news, it's completely hosed. The adapter does some indistinguishable 
>> blinking for a second, then stops blinking alltogether.
> 
> Weird.  I tested it on the only e100 I have access to, and it worked.
> I've just reviewed the patch you quoted below, and I don't see what the
> problem is.  

I don't understand it either, and will dig into this after I get more coffee.

point is that `ethtool -p` now exits immediately after 500ms. it should loop until ^C is 
pressed. Somehow msleep_interruptable is always returning 0 on my platform? very strange.

Auke
