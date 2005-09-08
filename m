From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/1] ipw2100: remove by-hand function entry/exit debugging
Date: Wed, 07 Sep 2005 20:52:22 -0400
Message-ID: <431F8B46.8020209@pobox.com>
References: <20050906.194111.130652562.davem@davemloft.net>	<431E5514.2070003@pobox.com>	<200509071539.08780.netdev@axxeo.de> <20050907.130151.71544363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, akpm@osdl.org, pavel@ucw.cz,
	ipw2100-admin@linux.intel.com, pavel@suse.cz,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932494AbVIHAwi@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050907.130151.71544363.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Ingo Oeser <netdev@axxeo.de>
> Date: Wed, 7 Sep 2005 15:39:08 +0200
> 
> 
>>Jeff Garzik wrote:
>>
>>>I find them useful in my own drivers; they are definitely not pure noise.
>>
>>gcc -finstrument-functions
> 
> 
> I was going to mention this as well, and also the idea to
> enable CONFIG_MCOUNT on a per-file basis.
> 
> We should never be doing by hand what can be automated.


As long as nobody breaks the primary maintainer's primary method of 
debugging, patches are welcome...

	Jeff
