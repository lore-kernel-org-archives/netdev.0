From: Loic Prylli <loic@myri.com>
Subject: Re: [PATCH] pciaer: report config read/write errors
Date: Tue, 02 Dec 2008 15:14:35 -0500
Message-ID: <4935972B.8050608@myri.com>
References: <20081202004115.12058.64881.stgit@gitlost.lost>	<20081201174754.2e5ef401@extreme>	<20081201.232527.66213356.davem@davemloft.net>	<20081202092316.7d6b6291@extreme>	<493586AF.3030402@myri.com> <20081202114441.4389fab7@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org,
	peter.p.waskiewicz.jr@intel.com, linux-pci@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1978 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750718AbYLBUOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 15:14:45 -0500
In-Reply-To: <20081202114441.4389fab7@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/2008 02:44 PM, Stephen Hemminger wrote:
> pci_find_ext_capability would succeed but all access to registers >= 256
> would fail if MMCONFIG failed. 



Your sentence seems self-contradicting to me. pci_find_ext_capability() 
(!=  pci_find_capability()) only tries to access registers >= 256, so I 
don't see how it would succeed if *all* those accesses are failing.


> P.s: you can look back into LKML for Linus discussion about why MMCONFIG
> is broken anyway.
>   



I was an active participant in one of those discussions (although it is 
possible I missed a later one), so I am quite aware about the 
limitations of MMCONFIG. But pci_find_ext_capability() looked to me a 
good filter to check about those limitations().

This is not just about pciaer, for instance, it might be that a lot of 
the SR-IOV code submitted recently assumes that if the corresponding 
extended-capability can be detected, little checking needs to be done 
afterwards.


Loic


