From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next 2/6] bluetooth: Convert uses of __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 10:26:06 -0700
Message-ID: <F2E9571C-2D55-4529-A361-D8CD4B3FC491@holtmann.org>
References: <cover.1394643455.git.joe@perches.com> <51892631f2289665bf47b294c783ee9560a8317e.1394643455.git.joe@perches.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51892631f2289665bf47b294c783ee9560a8317e.1394643455.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

> The use of __constant_<foo> has been unnecessary for quite awhile now=
=2E
>=20
> Make these uses consistent with the rest of the kernel.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> net/bluetooth/a2mp.c        |  4 +-
> net/bluetooth/hci_conn.c    | 26 ++++++-------
> net/bluetooth/hci_core.c    |  2 +-
> net/bluetooth/hci_event.c   |  6 +--
> net/bluetooth/hci_sock.c    | 16 ++++----
> net/bluetooth/l2cap_core.c  | 90 ++++++++++++++++++++++--------------=
---------
> net/bluetooth/l2cap_sock.c  |  6 +--
> net/bluetooth/mgmt.c        | 26 ++++++-------
> net/bluetooth/rfcomm/core.c |  4 +-
> net/bluetooth/sco.c         | 10 ++---
> net/bluetooth/smp.c         |  2 +-
> 11 files changed, 96 insertions(+), 96 deletions(-)

can you please send this one against bluetooth-next tree. I did a quick=
 check if it would by chance apply cleanly, but it doesn=92t.

I am happy to take this change, but it has to go through bluetooth-next=
=2E Otherwise you are conflicting with work from everybody else.

Regards

Marcel
