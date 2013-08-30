From: Fabio Estevam <festevam@gmail.com>
Subject: Re: 1f324e3 ipv6: Don't depend on per socket memory for neighbour
 discovery messages
Date: Fri, 30 Aug 2013 18:19:21 -0300
Message-ID: <CAOMZO5AHm5UO8LJ6WNThSABRHO3BoAb82hOAB+2B=rypJGY4dQ@mail.gmail.com>
References: <5220F691.4020808@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <5220F691.4020808@wwwdotorg.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 30, 2013 at 4:46 PM, Stephen Warren <swarren@wwwdotorg.org> wrote:
> Commit 1f324e3 "ipv6: Don't depend on per socket memory for neighbour
> discovery messages" appears to cause issues for me. If I run
> next-20130830, I see the issue, but if I then just revert that one
> patch, I don't see any problem, and can use the network without issue.
>
> The problem is: with a network device enabled (in my case, a USB
> Ethernet dongle, although I don't know if the type is relevant), then
> the system appears to hang soon after enabling the interface; neither
> the serial console nor the framebuffer echo my typing, and the cursor on
> the framebuffer stops flashing. After a short delay, I see the following
> kernel spew:

I see the same problem on a ARM system (mx6 board) using the built-in
ethernet driver (fec).
