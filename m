From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: 2.6.34.1 page allocation failure
Date: Tue, 31 Aug 2010 22:28:13 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1008311655450.8562@uplift.swm.pp.se>
References: <4C70BFF3.8030507@hardwarefreak.com> <alpine.DEB.1.10.1008220842400.8562@uplift.swm.pp.se> <AANLkTin48SJ58HvFqjrOnQBMqLcbECtqXokweV00dNgv@mail.gmail.com> <alpine.DEB.2.00.1008221734410.21916@router.home> <4C724141.8060000@kernel.org>
 <4C72F7C6.3020109@hardwarefreak.com> <4C74097A.5020504@kernel.org> <alpine.DEB.1.10.1008242114120.8562@uplift.swm.pp.se> <4C7A3B1D.7050500@kernel.org> <alpine.DEB.1.10.1008291433420.8562@uplift.swm.pp.se> <4C7A5DDE.8030106@kernel.org>
 <alpine.DEB.1.10.1008291736170.8562@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Stan Hoeppner <stan@hardwarefreak.com>,
	Christoph Lameter <cl@linux.com>,
	Linux Kernel List <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pekka Enberg <penberg@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.1008291736170.8562@uplift.swm.pp.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 29 Aug 2010, Mikael Abrahamsson wrote:

> On Sun, 29 Aug 2010, Pekka Enberg wrote:
>
>> There aren't any debug options that need to be enabled. The reason I'm 
>> asking is because we had a bunch of similar issues being reported earlier 
>> that got fixed and it's been calm for a while. That's why it would be 
>> interesting to know if 2.6.35 or 2.6.36-rc2 (if it's not too unstable to 
>> test) fixes things.
>
> Oki, I have installed 2.6.35 now (found backport from ubuntu 10.10 for 
> 10.04), just need to do a reboot at some convenient time.

I just rebooted and ran a similar load of network+disk load that made the 
machine give "swapper allocation failure" messages before, and I couldn't 
reproduce it with 2.6.35:

2.6.35-19-generic #25~lucid1-Ubuntu SMP Wed Aug 25 03:50:05 UTC 2010 x86_64 GNU/Linux

Doing "sync" in the middle made sync take more than 5+ minutes to complete 
(2 hung-task messages in dmesg), but at least nothing ran out of memory.

Considering the amount of people running 2.6.32 and who will be running it 
in the future, it still worries me that this is present in 2.6.32 (and 
earlier kernels as well).

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
