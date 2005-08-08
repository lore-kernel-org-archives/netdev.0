From: Patrick McHardy <kaber@trash.net>
Subject: Re: Netlink allocation for iSCSI and others
Date: Mon, 08 Aug 2005 23:19:37 +0200
Message-ID: <42F7CC69.3060808@trash.net>
References: <20050808.134731.74751192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, James.Bottomley@SteelEye.com,
	itn780@yahoo.com, linux-scsi@vger.kernel.org, hch@lst.de,
	akpm@osdl.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050808.134731.74751192.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> So we can increase MAX_LINKS to 256 and that's what I think I will do
> for 2.6.14 unless there is a very serious objection.  The tables sized
> by MAX_LINKS in af_netlink.c are dynamically allocated, and the only
> linear iterations over MAX_LINKS are for the netlink socket procfs
> seq-file dumper, so it's not a performance issue either.

I think we should increase it when allocating new numbers to save the
unused memory for the larger nltable and additional pid hashes.
Userspace shouldn't care if we change it.
