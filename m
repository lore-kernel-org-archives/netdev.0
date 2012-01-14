From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of
 failing probe
Date: Sat, 14 Jan 2012 11:56:04 -0800 (PST)
Message-ID: <20120114.115604.2101782124431552110.davem@davemloft.net>
References: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com>
	<20120114.001430.787918662083526597.davem@davemloft.net>
	<4F11A533.4040406@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, arjan@linux.intel.com,
	alan@linux.intel.com, tomoya.rohm@gmail.com,
	jeffrey.t.kirsher@intel.com, paul.gortmaker@windriver.com,
	jdmason@kudzu.us, netdev@vger.kernel.org
To: dvhart@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756386Ab2ANT4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 14:56:13 -0500
In-Reply-To: <4F11A533.4040406@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Darren Hart <dvhart@linux.intel.com>
Date: Sat, 14 Jan 2012 07:54:27 -0800

>> Please correct any hardware that hasn't shipped yet or is alpha/beta
>> hardware in testing, so that we don't need stuff like this.
> 
> I saw that the use of random_ether_addr is fairly prevalent, and
> attempted a roughly similar sort of approach to others I had seen. Do
> you consider all of those to be "necessary evils" or are there
> legitimate situations for its use?
> 
> In any case, with existing hardware out there that is unusable with the
> current pch_gbe driver, can we consider this workaround for inclusion?

I fear that people are just going to add this random MAC stuff way too
easily, it's a spreading disease.

Ship functional hardware instead.
