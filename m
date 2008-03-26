From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: Re: [Devel] Re: [PATCH 1/2 net-2.6.26] [NETNS]: Compilation fix for include/linux/netdevice.h.
Date: Wed, 26 Mar 2008 12:22:21 +0300
Message-ID: <200803261222.22409.adobriyan@sw.ru>
References: <1206517259-29152-1-git-send-email-den@openvz.org> <20080326.004742.92048899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, den@openvz.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: devel@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:38094 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756515AbYCZJXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 05:23:18 -0400
In-Reply-To: <20080326.004742.92048899.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 26 March 2008 10:47:42 David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Wed, 26 Mar 2008 10:40:58 +0300
>
> > Commit commit c346dca10840a874240c78efe3f39acf4312a1f2
> > ([NET] NETNS: Omit net_device->nd_net without CONFIG_NET_NS)
> > breaks compilation with CONFIG_NET_NS set.
> >
> > Fix the typo.
> >
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
>
> Applied.
>
> Too bad allmodconfig doesn't enable things which are y/n only.

Right now NET_NS can be more or less reliably selected via:

    echo '# CONFIG_SYSFS is not set' >foo
    echo 'CONFIG_NET_NS=y'           >>foo
    KCONFIG_ALLCONFIG=foo make allmodconfig

But this trick a) doesn't work with some options, b) likely to break when
someone will start selecting SYSFS.
