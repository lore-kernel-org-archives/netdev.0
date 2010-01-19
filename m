From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for January 19 (vhost_net)
Date: Tue, 19 Jan 2010 10:41:39 -0800
Message-ID: <20100119104139.2ec9164b.randy.dunlap@oracle.com>
References: <20100119181041.ab55f645.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100119181041.ab55f645.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Jan 2010 18:10:41 +1100 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20100118:


When CONFIG_TUN is not enabled:

drivers/built-in.o: In function `get_socket':
net.c:(.text+0x2899a3): undefined reference to `tun_get_socket'


so VHOST_NET can either depend on TUN or select TUN, but if it
selects TUN, it will also need to select CRC32.

---
~Randy
