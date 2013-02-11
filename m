From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Netfilter/IPVS fixes for 3.8-rc7
Date: Sun, 10 Feb 2013 20:44:33 -0500 (EST)
Message-ID: <20130210.204433.2226777707133667878.davem@davemloft.net>
References: <1360411440-6526-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1360411440-6526-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Sat,  9 Feb 2013 13:03:55 +0100

> The following patchset contains Netfilter/IPVS fixes for 3.8-rc7, they are:
> 
> * Fix oops in IPVS state-sync due to releasing a random memory area due
>   to unitialized pointer, from Dan Carpenter.
> 
> * Fix SCTP flow establishment due to bad checksumming mangling in IPVS,
>   from Daniel Borkmann.
> 
> * Three fixes for the recently added IPv6 NPT, all from YOSHIFUJI Hideaki,
>   with an amendment collapsed into those patches from Ulrich Weber. They
>   fiix adjustment calculation, fix prefix mangling and ensure LSB of
>   prefixes are zeroes (as required by RFC).
> 
> Specifically, it took me a while to validate the 1's complement arithmetics/
> checksumming approach in the IPv6 NPT code.
> 
> It's fairly late stage, so let me know if you can still pull these from:
> 
> git://1984.lsi.us.es/nf master

Pulled, thanks Pablo.
