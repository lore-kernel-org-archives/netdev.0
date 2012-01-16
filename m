From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH 1/6] netback: page pool version 1
Date: Mon, 16 Jan 2012 09:31:12 +0000
Message-ID: <1326706272.5285.3.camel@liuw-desktop>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
	 <1326473949-22389-2-git-send-email-wei.liu2@citrix.com>
	 <20120113173746.GA16182@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:60018 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833Ab2APJc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 04:32:28 -0500
In-Reply-To: <20120113173746.GA16182@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-13 at 17:37 +0000, Konrad Rzeszutek Wilk wrote:
> > +static idx_t free_head;
> > +static int free_count;
> > +static unsigned long pool_size;
> > +static DEFINE_SPINLOCK(pool_lock);
> > +static struct page_pool_entry *pool;
> > +
> > +static int get_free_entry(void)
> > +{
> > +	unsigned long flag;
> > +	int idx;
> > +
> > +	spin_lock_irqsave(&pool_lock, flag);
> 
> What is the benfit of using the irq version of the spinlock instead
> of the normal one??
> 

This should be vestige of iterations, fixed.

Thanks
Wei.
