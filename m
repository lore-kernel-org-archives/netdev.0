From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] fix NFQUEUE Kconfig dependency
Date: Sat, 24 Sep 2005 16:52:18 -0700 (PDT)
Message-ID: <20050924.165218.131424970.davem@davemloft.net>
References: <20050923014412.26695cc4.akpm@osdl.org>
	<433412A6.2090904@trash.net>
	<20050923150631.GH731@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, akpm@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750792AbVIXXwm@vger.kernel.org>
To: laforge@netfilter.org
In-Reply-To: <20050923150631.GH731@sunbeam.de.gnumonks.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Harald Welte <laforge@netfilter.org>
Date: Fri, 23 Sep 2005 17:06:31 +0200

> [NETFILTER]: Fix ip[6]t_NFQUEUE Kconfig dependency
> 
> We have to introduce a separate Kconfig menu entry for the NFQUEUE targets.
> They cannot "just" depend on nfnetlink_queue, since nfnetlink_queue could
> be linked into the kernel, whereas iptables can be a module.
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>

Applied, thanks Harald.
