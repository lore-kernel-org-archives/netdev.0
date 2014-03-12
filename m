From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH V2 bluetooth-next 2/6] bluetooth: Convert uses of __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 11:11:13 -0700
Message-ID: <34E193D0-F15B-4C23-83F7-697096916D4D@holtmann.org>
References: <cover.1394643455.git.joe@perches.com> <51892631f2289665bf47b294c783ee9560a8317e.1394643455.git.joe@perches.com> <F2E9571C-2D55-4529-A361-D8CD4B3FC491@holtmann.org> <1394646755.3915.8.camel@joe-AO722>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Network Development <netdev@vger.kernel.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394646755.3915.8.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

> The use of __constant_<foo> has been unnecessary for quite awhile now.
> 
> Make these uses consistent with the rest of the kernel.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
>> can you please send this one against bluetooth-next tree.
> 
> Sure.  Here.  btw:
> 
> The bandwidth uses of 0x1f40 are kind of unreadable to me.
> I think they'd be better as 8000
> 
> Also some of the hex constants uses seem odd where comments
> don't seem to match the number like: 
> 
> 	/* Connection accept timeout ~20 secs */
> -	param = __constant_cpu_to_le16(0x7d00);
> +	param = cpu_to_le16(0x7d00);
> 
> 0x7d00 is 32000, presumably that's 32 seconds.

so it is 0x7d00 * 0.625 which results in 20 seconds.

> 
> and
> 
> 		/* 160 msec page scan interval */
> -		acp.interval = __constant_cpu_to_le16(0x0100);
> +		acp.interval = cpu_to_le16(0x0100);
> 
> 256 msecs?

also here 0x0100 * 0.625 resulting in 160 msecs.

> net/bluetooth/a2mp.c        |  4 +-
> net/bluetooth/hci_conn.c    | 26 ++++++-------
> net/bluetooth/hci_core.c    |  2 +-
> net/bluetooth/hci_event.c   |  6 +--
> net/bluetooth/hci_sock.c    | 16 ++++----
> net/bluetooth/l2cap_core.c  | 90 ++++++++++++++++++++++-----------------------
> net/bluetooth/l2cap_sock.c  |  6 +--
> net/bluetooth/mgmt.c        | 26 ++++++-------
> net/bluetooth/rfcomm/core.c |  4 +-
> net/bluetooth/sco.c         | 10 ++---
> net/bluetooth/smp.c         |  2 +-
> 11 files changed, 96 insertions(+), 96 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
