From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net bridge: add null pointer check, fix panic
Date: Thu, 20 Jun 2013 01:14:00 -0700
Message-ID: <1371716040.3252.389.camel@edumazet-glaptop>
References: <51C2710D.2060405@gmail.com> <51C2721B.9050603@gmail.com>
	<1371704129.3252.356.camel@edumazet-glaptop>
	<51C2A8AA.5010902@gmail.com>
	<1371713342.3252.371.camel@edumazet-glaptop>
	<51C2B3A9.5070904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: xiaoming gao <gxm.linux.kernel@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <51C2B3A9.5070904@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-20 at 15:47 +0800, xiaoming gao wrote:

> 
> if you remove the test on FF_BRIDGE_PORT, and br_port_get_rcu never returns NULL, the problem is fixed.
> but the codes in mainline is still bugged, am i right??
> by the way, kernel-stable 3.0 and 3.4 tree also have this bug, and is very easily to reproduce.

Commit 00cfec37484761a4 has to be backported anyway, if not already
backported.

I would rather fix things properly, instead of adding defensive code.
