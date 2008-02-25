From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] nf_conntrack: less hairy ifdefs around proc and sysctl
Date: Mon, 25 Feb 2008 14:13:53 +0100
Message-ID: <47C2BF11.8070108@trash.net>
References: <20080225095428.GA3789@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep31-int.chello.at ([62.179.121.49]:58513 "EHLO
	viefep31-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbYBYNN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 08:13:59 -0500
In-Reply-To: <20080225095428.GA3789@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Patch splits creation of /proc/net/nf_conntrack, /proc/net/stat/nf_conntrack
> and net.netfilter hierarchy into their own functions with dummy ones
> if PROC_FS or SYSCTL is not set. Also, remove dead "ret = 0" write
> while I'm at it.

Queued for 2.6.26, thanks.
