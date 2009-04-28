From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: storage address support
Date: Tue, 28 Apr 2009 02:12:49 -0700 (PDT)
Message-ID: <20090428.021249.247190041.davem@davemloft.net>
References: <20090427222800.GA14396@cleech-lnx.jf.intel.com>
	<20090427.184854.227522560.davem@davemloft.net>
	<20090428083048.GB27798@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christopher.leech@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org
To: jpirko@redhat.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090428083048.GB27798@psychotron.englab.brq.redhat.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 28 Apr 2009 10:30:48 +0200

> Tue, Apr 28, 2009 at 03:48:54AM CEST, davem@davemloft.net wrote:
>>From: Chris Leech <christopher.leech@intel.com>
>>Date: Mon, 27 Apr 2009 15:28:00 -0700
>>
>>> Ignoring the issue of intended use for the moment, if an ethernet driver
>>> wanted to advertise several MAC addresses to the system how should it go
>>> about that?
>>
>>Now that's a more interesting question.
>>
>>It seems better to formalize this.   It can be an ethtool
>>callback or whatever, but what it should do is return
>>an array of addresses, types, and perhaps even indexes
>>with types.
> 
> Well the list of device addresses from my patch can pretty much solve this.
> There can be additional field in struct netdev_hw_addr to store flags to
> identify the mac address type (like primary, lan, san, slave, etc).
> 
> I think it would be better to do this in general (in struct net_device) then
> inside each driver exported by ethtool or whatever.

Agreed, can you update your patch to provide such a 'type' tag?

Thanks!
