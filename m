From: David Miller <davem@davemloft.net>
Subject: Re: netns 01/02: add
 register_pernet_gen_subsys/unregister_pernet_gen_subsys
Date: Thu, 30 Oct 2008 23:55:25 -0700 (PDT)
Message-ID: <20081030.235525.194316718.davem@davemloft.net>
References: <20081030073143.14487.24299.sendpatchset@x2.localnet>
	<20081030073145.14487.48665.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081030073145.14487.48665.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 30 Oct 2008 08:31:46 +0100 (MET)

>     netns: add register_pernet_gen_subsys/unregister_pernet_gen_subsys
>     
>     netns ops which are registered with register_pernet_gen_device() are
>     shutdown strictly before those which are registered with
>     register_pernet_subsys(). Sometimes this leads to opposite (read: buggy)
>     shutdown ordering between two modules.
>     
>     Add register_pernet_gen_subsys()/unregister_pernet_gen_subsys() for modules
>     which aren't elite enough for entry in struct net, and which can't use
>     register_pernet_gen_device(). PPTP conntracking module is such one.
>     
>     Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
