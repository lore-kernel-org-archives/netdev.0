From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: storage address support
Date: Mon, 27 Apr 2009 18:48:54 -0700 (PDT)
Message-ID: <20090427.184854.227522560.davem@davemloft.net>
References: <20090424080349.30460.73770.stgit@localhost.localdomain>
	<20090427.030103.88777540.davem@davemloft.net>
	<20090427222800.GA14396@cleech-lnx.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, linux-scsi@vger.kernel.org
To: christopher.leech@intel.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090427222800.GA14396@cleech-lnx.jf.intel.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Leech <christopher.leech@intel.com>
Date: Mon, 27 Apr 2009 15:28:00 -0700

> Ignoring the issue of intended use for the moment, if an ethernet driver
> wanted to advertise several MAC addresses to the system how should it go
> about that?

Now that's a more interesting question.

It seems better to formalize this.   It can be an ethtool
callback or whatever, but what it should do is return
an array of addresses, types, and perhaps even indexes
with types.

So you could return LAN1, LAN2, LAN3, and SAN1.
