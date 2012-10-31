From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] [PATCH] net: allow configuration of the size of
 page in __netdev_alloc_frag
Date: Wed, 31 Oct 2012 12:19:06 +0100
Message-ID: <1351682346.32673.54.camel@edumazet-glaptop>
References: <1351078936-14159-1-git-send-email-ian.campbell@citrix.com>
	 <1351081703.6537.99.camel@edumazet-glaptop>
	 <1351084618.18035.27.camel@zakaz.uk.xensource.com>
	 <1351085403.6537.102.camel@edumazet-glaptop>
	 <1351087326.18035.50.camel@zakaz.uk.xensource.com>
	 <1351092068.6537.107.camel@edumazet-glaptop>
	 <1351095739.18035.83.camel@zakaz.uk.xensource.com>
	 <1351097000.6537.109.camel@edumazet-glaptop>
	 <20121030165309.GA30483@phenom.dumpdata.com>
	 <20121030172352.GA31997@phenom.dumpdata.com>
	 <20121031110149.GA6376@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Konrad Rzeszutek Wilk <konrad@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:44098 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934387Ab2JaLTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 07:19:09 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so4095842wib.1
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 04:19:08 -0700 (PDT)
In-Reply-To: <20121031110149.GA6376@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-31 at 07:01 -0400, Konrad Rzeszutek Wilk wrote:

> Argh. Please disregard this test. I added an extra patch in the kernel
> tree to track the SWIOTLB bounce usage and print it.. and the printk was
> going out to the FB, which was not too fast - so the whole test was being
> slowed down by FB drivers :-)
> 
> Will re-run this test without the offending patch.

Anyway, I must confess I didnt understand what you did ;)
