From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] nfnetlink_log: unset nf_loggers for net namespace when
 unload nfnetlink_log
Date: Fri, 20 Dec 2013 10:39:27 +0100
Message-ID: <20131220093927.GA13151@localhost>
References: <20131214101042.5626c785@gandalf.local.home>
 <1387177162-2725-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	lclaudio@uudg.org, williams@redhat.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49564 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756126Ab3LTJjc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 04:39:32 -0500
Content-Disposition: inline
In-Reply-To: <1387177162-2725-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 02:59:22PM +0800, Gao feng wrote:
> Steven Rostedt and Arnaldo Carvalho de Melo reported a panic
> when access the files /proc/sys/net/netfilter/nf_log/*.
> 
> This problem will occur when we do
> echo nfnetlink_log > /proc/sys/net/netfilter/nf_log/any_file
> ,rmmod nfnetlink_log, and then access the files.
> 
> Since the nf_loggers of netns hasn't been unset, it will point
> to the memory that has been freed.
> 
> This bug is introduced by commit 9368a53c471b42a1bd99117d590ce2ccdc8dc3c2
> "netfilter: nfnetlink_log: add net namespace support for nfnetlink_log"

Applied, thanks.
