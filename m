From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Netlink allocation for iSCSI and others
Date: Mon, 08 Aug 2005 14:21:22 -0700 (PDT)
Message-ID: <20050808.142122.104034267.davem@davemloft.net>
References: <20050808.134731.74751192.davem@davemloft.net>
	<42F7CC69.3060808@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, James.Bottomley@SteelEye.com,
	itn780@yahoo.com, linux-scsi@vger.kernel.org, hch@lst.de,
	akpm@osdl.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: kaber@trash.net
In-Reply-To: <42F7CC69.3060808@trash.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 08 Aug 2005 23:19:37 +0200

> David S. Miller wrote:
> > So we can increase MAX_LINKS to 256 and that's what I think I will do
> > for 2.6.14 unless there is a very serious objection.  The tables sized
> > by MAX_LINKS in af_netlink.c are dynamically allocated, and the only
> > linear iterations over MAX_LINKS are for the netlink socket procfs
> > seq-file dumper, so it's not a performance issue either.
> 
> I think we should increase it when allocating new numbers to save the
> unused memory for the larger nltable and additional pid hashes.
> Userspace shouldn't care if we change it.

Agreed.  So we have 17 netlink numbers to allocate at this
point, and that should be good for a while.
