From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] network: tcp_connect should return certain errors
 up the stack
Date: Wed, 17 Nov 2010 10:56:00 -0800 (PST)
Message-ID: <20101117.105600.179937042.davem@davemloft.net>
References: <20101116215238.6727.39248.stgit@paris.rdu.redhat.com>
	<20101116215249.6727.89763.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	selinux@tycho.nsa.gov, netfilter-devel@vger.kernel.org,
	equinox@diac24.net, eric.dumazet@gmail.com, hzhong@gmail.com,
	jmorris@namei.org, kaber@trash.net, kuznet@ms2.inr.ac.ru,
	paul.moore@hp.com, pekkas@netcore.fi, sds@tycho.nsa.gov,
	yoshfuji@linux-ipv6.org
To: eparis@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101116215249.6727.89763.stgit@paris.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Paris <eparis@redhat.com>
Date: Tue, 16 Nov 2010 16:52:49 -0500

> The current tcp_connect code completely ignores errors from sending an skb.
> This makes sense in many situations (like -ENOBUFFS) but I want to be able to
> immediately fail connections if they are denied by the SELinux netfilter hook.
> Netfilter does not normally return ECONNREFUSED when it drops a packet so we
> respect that error code as a final and fatal error that can not be recovered.
> 
> Based-on-patch-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Eric Paris <eparis@redhat.com>

Applied.
