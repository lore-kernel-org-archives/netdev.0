From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH net-next v2 1/3] net: rename include/net/ll_poll.h
 to include/net/busy_poll.h
Date: Wed, 10 Jul 2013 15:17:57 +0200
Message-ID: <51DD5F05.6030206@broadcom.com>
References: <20130710121349.12906.85078.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Don Skidmore" <donald.c.skidmore@intel.com>,
	"Jonathan Corbet" <corbet@lwn.net>,
	e1000-devel@lists.sourceforge.net,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Amir Vadai" <amirv@mellanox.com>,
	"Eric Dumazet" <erdnetdev@gmail.com>,
	"Willem de Bruijn" <willemb@google.com>,
	"Eliezer Tamir" <eliezer@tamir.org.il>
To: "Eliezer Tamir" <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130710121349.12906.85078.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/10/2013 02:13 PM, Eliezer Tamir wrote:
> Rename the file and correct all the places where it is included.
>
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> ---
>
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2
>   drivers/net/ethernet/intel/ixgbe/ixgbe.h        |    2
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    2
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c      |    2
>   fs/select.c                                     |    2
>   include/net/busy_poll.h                         |  183 +++++++++++++++++++++++
>   include/net/ll_poll.h                           |  183 -----------------------
>   net/core/datagram.c                             |    2
>   net/core/sock.c                                 |    2
>   net/core/sysctl_net_core.c                      |    2
>   net/ipv4/tcp.c                                  |    2
>   net/ipv4/tcp_ipv4.c                             |    2
>   net/ipv4/udp.c                                  |    2
>   net/ipv6/tcp_ipv6.c                             |    2
>   net/ipv6/udp.c                                  |    2
>   net/socket.c                                    |    2
>   16 files changed, 197 insertions(+), 197 deletions(-)
>   create mode 100644 include/net/busy_poll.h
>   delete mode 100644 include/net/ll_poll.h

Did you use -M command line option with 'git format-patch'?

Gr. AvS
