From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] secmark: do not return early if there was no error
Date: Fri, 15 Oct 2010 17:08:26 +0200
Message-ID: <4CB86E6A.1040807@trash.net>
References: <20101013202105.15011.60553.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	davem@davemloft.net, jengelh@medozas.de, paul.moore@hp.com,
	jmorris@namei.org
To: Eric Paris <eparis@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101013202105.15011.60553.stgit@paris.rdu.redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 13.10.2010 22:21, schrieb Eric Paris:
> Commit 4a5a5c73 attempted to pass decent error messages back to userspace for
> netfilter errors.  In xt_SECMARK.c however the patch screwed up and returned
> on 0 (aka no error) early and didn't finish setting up secmark.  This results
> in a kernel BUG if you use SECMARK.
> 
> ------------[ cut here ]------------
> kernel BUG at net/netfilter/xt_SECMARK.c:38!
> invalid opcode: 0000 [#1] SMP
> last sysfs file: /sys/devices/system/cpu/cpu2/cache/index2/shared_cpu_map
> CPU 0
> Modules linked in: xt_SECMARK iptable_mangle nfs lockd fscache nfs_acl
> auth_rpcgss sunrpc ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables
> uinput virtio_net virtio_balloon i2c_piix4 i2c_core joydev microcode ipv6
> virtio_blk virtio_pci virtio_ring virtio [last unloaded: speedstep_lib]
> 
> ...
> RIP  [<ffffffffa022117d>] secmark_tg+0x17/0x2e [xt_SECMARK]
> RSP <ffff880003e03a40>
> ---[ end trace 9aa5d06a71143e74 ]---
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>
> Acked-by: Paul Moore <paul.moore@hp.com>
> Acked-by: James Morris <jmorris@namei.org>

Acked-by: Patrick McHardy <kaber@trash.net>

I'll leave it up to Dave whether this can still go into 2.6.36.
