From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: Tue, 25 Jan 2005 22:27:05 -0800
Message-ID: <20050125222705.1ee878fd.davem@davemloft.net>
References: <527jmu8nbw.fsf@topspin.com>
	<5cac192f0501030907c755135@mail.gmail.com>
	<20050103171227.GD7370@esmail.cup.hp.com>
	<1104812294.1085.53.camel@jzny.localdomain>
	<20050119144711.3fdd3d93.davem@davemloft.net>
	<20050119151853.259de49a@dxpl.pdx.osdl.net>
	<20050119164640.6c67bdfa.davem@davemloft.net>
	<52r7kgu5n5.fsf@topspin.com>
	<20050119230526.393a5184.davem@davemloft.net>
	<20050120085611.33f9485e@dxpl.pdx.osdl.net>
	<20050121105452.GA12988@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, roland@topspin.com, hadi@cyberus.ca, iod00d@hp.com,
        eric.lemoine@gmail.com, netdev@oss.sgi.com, ak@suse.de,
        openib-general@openib.org, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050121105452.GA12988@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 Jan 2005 11:54:52 +0100
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> If multiple CPUs can call into the tunneling drivers without taking
> any locks, we'd need some extra locking in there, or just do what
> Alexey describes and keep track of recursion in the skb.

Another idea is that, just like how loopback made it's statistics
per-cpu for LLTX support, this recursion variable could be per-cpu
as well.
