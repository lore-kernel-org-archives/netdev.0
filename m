From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: tipc: Delete error messages for failed memory allocations in
 three functions
Date: Tue, 23 May 2017 18:23:17 +0200
Message-ID: <d07d0b1f-0038-e91d-4748-ea3e6dfb93f0@users.sourceforge.net>
References: <7ac9d513-6f9f-a096-e68f-81a722c2723c@users.sourceforge.net>
 <1495548133.2093.58.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>,
        tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:59726 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758912AbdEWQXx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 12:23:53 -0400
In-Reply-To: <1495548133.2093.58.camel@perches.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> tipc_subseq_alloc does a kcalloc (memset to 0),
> half of which is immediately overwritten.
> 
> In other words, don't just blindly remove stuff,
> understand what it does and improve it.

Do you suggest another specific source code transformation pattern here?

Regards,
Markus
