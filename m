From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: allow logging from non-init namespaces
Date: Thu, 12 May 2016 11:57:26 +0200
Message-ID: <20160512095726.GA1975@salvia>
References: <20160428074838.0BBB5A0C94@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jonathan Corbet <corbet@lwn.net>, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42720 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752615AbcELJ5c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2016 05:57:32 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 45CE71B5341
	for <netdev@vger.kernel.org>; Thu, 12 May 2016 11:57:29 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 3643C2687CC
	for <netdev@vger.kernel.org>; Thu, 12 May 2016 11:57:29 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 14FFDA827A
	for <netdev@vger.kernel.org>; Thu, 12 May 2016 11:57:27 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20160428074838.0BBB5A0C94@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michal,

On Wed, Apr 27, 2016 at 02:48:02PM +0200, Michal Kubecek wrote:
> Commit 69b34fb996b2 ("netfilter: xt_LOG: add net namespace support for
> xt_LOG") disabled logging packets using the LOG target from non-init
> namespaces. The motivation was to prevent containers from flooding
> kernel log of the host. The plan was to keep it that way until syslog
> namespace implementation allows containers to log in a safe way.
> 
> However, the work on syslog namespace seems to have hit a dead end
> somewhere in 2013 and there are users who want to use xt_LOG in all
> network namespaces. This patch allows to do so by setting

I understand this stuff is tricky. Did you contact already namespace
folks to see if they plan any move on this?

>   /proc/sys/net/netfilter/nf_log_all_netns

My only concern with this is that I don't see how users know what log
message has triggered from what container.

Thanks!
