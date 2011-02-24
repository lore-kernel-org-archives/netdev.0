From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH] cxgb{3,4}: streamline Kconfig options
Date: Thu, 24 Feb 2011 11:41:15 -0800
Message-ID: <4D66B45B.2050604@chelsio.com>
References: <4D5D30CA020000780003263A@vpn.id2.novell.com> <20110222.101457.39195901.davem@davemloft.net> <4D64E5720200007800033420@vpn.id2.novell.com> <20110223.122709.193705956.davem@davemloft.net> <4D661E2702000078000336B5@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, divy@chelsio.com,
	linux-kbuild@vger.kernel.org, netdev@vger.kernel.org
To: Jan Beulich <JBeulich@novell.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <4D661E2702000078000336B5@vpn.id2.novell.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Beulich wrote:

> As to that INET vs NET dependency - is it possible that the
> network drivers really just need NET, but the iSCSI ones need
> INET? In which case the only common dependency would be
> PCI - certainly not worth a custom helper option.

I see about a dozen network drivers that depend on INET.  These may be the 
result of cut&paste from other drivers' Kconfig entries rather than actual 
dependencies.  Also some of these drivers select or selected in the past 
INET_LRO and that may have something to do with their INET dependency, not sure.

Reading the commit message that introduced CHELSIO_T3_DEPENDS, it talks of 
hidden dependencies that select does not see.  I am not sure which exactly 
but since it's been a few years since that commit I'll try to see what the 
situation is today without the *_DEPENDS symbols and let you know.
