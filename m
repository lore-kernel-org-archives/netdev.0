From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] SELinux: return -ECONNREFUSED from ip_postroute to
 signal fatal error
Date: Wed, 17 Nov 2010 10:56:06 -0800 (PST)
Message-ID: <20101117.105606.245401574.davem@davemloft.net>
References: <20101116215238.6727.39248.stgit@paris.rdu.redhat.com>
	<20101116215257.6727.12163.stgit@paris.rdu.redhat.com>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101116215257.6727.12163.stgit@paris.rdu.redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Paris <eparis@redhat.com>
Date: Tue, 16 Nov 2010 16:52:57 -0500

> The SELinux netfilter hooks just return NF_DROP if they drop a packet.  We
> want to signal that a drop in this hook is a permanant fatal error and is not
> transient.  If we do this the error will be passed back up the stack in some
> places and applications will get a faster interaction that something went
> wrong.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

Applied.
