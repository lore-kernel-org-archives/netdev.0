From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Patch] bridge: call NETDEV_ENSLAVE notifiers when adding a
 slave
Date: Thu, 19 May 2011 08:12:13 -0700
Message-ID: <20110519081213.15c05da2@nehalam>
References: <1305794393-20775-1-git-send-email-amwang@redhat.com>
	<1305800661-4081-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	Neil Horman <nhorman@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305800661-4081-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 May 2011 18:24:17 +0800
Amerigo Wang <amwang@redhat.com> wrote:

> In the previous patch I added NETDEV_ENSLAVE, now
> we can notify netconsole when adding a device to a bridge too.
> 
> By the way, s/netdev_bonding_change/call_netdevice_notifiers/ in
> bond_main.c, since this is not bonding specific.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@redhat.com>
> 

Is there a usage for this? What listens for this notification?
