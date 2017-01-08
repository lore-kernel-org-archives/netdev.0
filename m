From: David Miller <davem@davemloft.net>
Subject: Re: patch 4.8 "net: handle no dst on skb in icmp6_send"
Date: Sun, 08 Jan 2017 17:50:08 -0500 (EST)
Message-ID: <20170108.175008.1125416899482175990.davem@davemloft.net>
References: <02a7e2d2-cc1d-1c64-ac9b-7daf8a834b56@spamcop.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: brok@spamcop.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43682 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753680AbdAHWuL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 17:50:11 -0500
In-Reply-To: <02a7e2d2-cc1d-1c64-ac9b-7daf8a834b56@spamcop.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bronek Kozicki <brok@spamcop.net>
Date: Sun, 8 Jan 2017 21:46:18 +0000

> Hello,
> 
> any particular reason why this fix
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=79dc7e3f1cd323be4c81aa1a94faa1b3ed987fb2
> was missed from stable 4.8 line? Apparently the bug being fixed has
> its own https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-9919
> 
> Thank you for your hard work and best regards

You should always check the networking -stable queue before asking
such questions:

	http://patchwork.ozlabs.org/bundle/davem/stable/?submitter=&state=*&q=&archive=

Every patch sitting there is queued up and will be submitted to -stable
at some time in the next week or two, or whenever I get around to vetting
and submitting -stable changes.

The patch you are asking about it in fact in there, and will be attended
to at an appropriate time.

Thanks.
