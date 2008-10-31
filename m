From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 02/02: nf_conntrack_proto_gre: switch to
 register_pernet_gen_subsys()
Date: Thu, 30 Oct 2008 23:55:57 -0700 (PDT)
Message-ID: <20081030.235557.206473899.davem@davemloft.net>
References: <20081030073143.14487.24299.sendpatchset@x2.localnet>
	<20081030073146.14487.64303.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081030073146.14487.64303.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 30 Oct 2008 08:31:47 +0100 (MET)

>     netfilter: nf_conntrack_proto_gre: switch to register_pernet_gen_subsys()
>     
>     register_pernet_gen_device() can't be used is nf_conntrack_pptp module is
>     also used (compiled in or loaded).
>     
>     Right now, proto_gre_net_exit() is called before nf_conntrack_pptp_net_exit().
>     The former shutdowns and frees GRE piece of netns, however the latter
>     absolutely needs it to flush keymap. Oops is inevitable.
>     
>     Switch to shiny new register_pernet_gen_subsys() to get correct ordering in
>     netns ops list.
>     
>     Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Also applied, thanks.
