From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: 31 Mar 2005 16:10:32 -0500
Message-ID: <1112303431.1073.67.camel@jzny.localdomain>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>
	 <20050331120410.7effa94d@dxpl.pdx.osdl.net>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050331120410.7effa94d@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-31 at 15:04, Stephen Hemminger wrote:
> Here is another alternative that seems better than the earlier posting. It uses
> a per device receive queue for non-NAPI devices.  The only issue is that then
> we lose the per-cpu queue's and that could impact the loopback device performance.
> If that is really an issue, then the per-cpu magic should be moved to the loopback
> device.
> 

The repurcassions of going from per-CPU-for-all-devices queue
(introduced by softnet) to per-device-for-all-CPUs maybe huge in my
opinion especially in SMP. A closer view of whats there now maybe
per-device-per-CPU backlog queue.
I think performance will be impacted in all devices. imo, whatever needs
to go in needs to have some experimental data to back it

cheers,
jamal
