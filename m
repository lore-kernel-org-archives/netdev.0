From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Tue, 11 Nov 2003 15:57:31 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB14D3B.8060200@pobox.com>
References: <3F844578.40306@sgi.com>	<20031008101046.376abc3b.davem@redhat.com>	<3F8455BE.8080300@sgi.com>	<20031008183742.GA24822@wotan.suse.de>	<20031008122223.1ba5ac79.davem@redhat.com>	<20031008202248.GA15611@oldwotan.suse.de>	<3F8702FF.70500@sgi.com>	<20031010192036.GA31727@wotan.suse.de>	<3F8802E6.5030601@sgi.com>	<20031011131921.GC21763@wotan.suse.de>	<20031011105054.0e16a607.davem@redhat.com>	<3F8C290A.3010508@sgi.com>	<20031014095323.71c8b9fe.davem@redhat.com>	<3FB03A56.7000709@sgi.com>	<20031110182911.2c5a121b.davem@redhat.com>	<3FB140E2.1070007@sgi.com> <20031111122545.6bb8bfe5.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johnip@sgi.com, ak@suse.de, netdev@oss.sgi.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031111122545.6bb8bfe5.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 11 Nov 2003 14:04:50 -0600
> John Partridge <johnip@sgi.com> wrote:
> 
> 
>>+config CONFIG_UNALIGNED_EXPENSIVE
>>+       bool "Use Aligned SKB's for Tigon3 5701 network adapters"
>>+       depends on MCKINLEY
>>+       default y
>>+
> 
> 
> Also, this help text is broken too.
> 
> I repeat: "THIS IS NOT A TIGON3 5701 NETWORK ADAPTER SPECIFIC HACK"
> 
> It is a config variable that all network drivers in the kernel can
> test to make copybreak and related decisions for copy vs. read
> directly packet handling.
> 
> Please stop making this a tigon3 specific thing.


We should CC David Mosberger on this, too.  He's been wanting something 
like this (for, as you say, all network drivers) for a while now.

	Jeff
