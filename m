From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/4) remove hashbin from irlan
Date: Tue, 19 Aug 2003 21:13:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819211355.2c8664ee.davem@redhat.com>
References: <20030818113936.205b5632.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030818113936.205b5632.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 11:39:36 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The locking in hashbin_delete is a problem since unregister_netdevice
> can't be called with locks held in 2.6.0-test3.
> 
> Replace it with simpler list macros.
> Insertion/deletion protected with RTNL semaphore, and read
> uses RCU.

Patch applied, thanks.
