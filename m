From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] netdev: storage address support
Date: Tue, 28 Apr 2009 10:30:48 +0200
Message-ID: <20090428083048.GB27798@psychotron.englab.brq.redhat.com>
References: <20090424080349.30460.73770.stgit@localhost.localdomain> <20090427.030103.88777540.davem@davemloft.net> <20090427222800.GA14396@cleech-lnx.jf.intel.com> <20090427.184854.227522560.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: christopher.leech@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090427.184854.227522560.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Apr 28, 2009 at 03:48:54AM CEST, davem@davemloft.net wrote:
>From: Chris Leech <christopher.leech@intel.com>
>Date: Mon, 27 Apr 2009 15:28:00 -0700
>
>> Ignoring the issue of intended use for the moment, if an ethernet driver
>> wanted to advertise several MAC addresses to the system how should it go
>> about that?
>
>Now that's a more interesting question.
>
>It seems better to formalize this.   It can be an ethtool
>callback or whatever, but what it should do is return
>an array of addresses, types, and perhaps even indexes
>with types.

Well the list of device addresses from my patch can pretty much solve this.
There can be additional field in struct netdev_hw_addr to store flags to
identify the mac address type (like primary, lan, san, slave, etc).

I think it would be better to do this in general (in struct net_device) then
inside each driver exported by ethtool or whatever.

>
>So you could return LAN1, LAN2, LAN3, and SAN1.
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
