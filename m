From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 07/10] dynamic_debug: make netdev_dbg() call
 __netdev_printk()
Date: Wed, 06 Jul 2011 14:50:29 -0700
Message-ID: <1309989029.1710.12.camel@Joe-Laptop>
References: <cover.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
	 <2ac0aaf4e955209cfad896c72fdb6b1491b021e1.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, jim.cromie@gmail.com, bvanassche@acm.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	aloisio.almeida@openbossa.org, netdev@vger.kernel.org
To: Jason Baron <jbaron@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2ac0aaf4e955209cfad896c72fdb6b1491b021e1.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-07-06 at 13:25 -0400, Jason Baron wrote:
> diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
[]
> @@ -503,6 +504,30 @@ int __dynamic_dev_dbg(struct _ddebug *descriptor,
[]
> +int __dynamic_netdev_dbg(struct _ddebug *descriptor,
> +		      const struct net_device *dev, const char *fmt, ...)
[]
> +	res += __netdev_printk("", dev, &vaf);

KERN_CONT here too.
