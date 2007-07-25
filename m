From: Mike Galbraith <efault@gmx.de>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Wed, 25 Jul 2007 07:09:03 +0200
Message-ID: <1185340143.6528.1.camel@Homer.simpson.net>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	 <20070723183839.GA5874@martell.zuzino.mipt.ru>
	 <20070723190152.GA5755@martell.zuzino.mipt.ru>
	 <20070723132431.42afbae8.akpm@linux-foundation.org>
	 <1185271269.6479.7.camel@Homer.simpson.net>
	 <20070724092839.f0556948.akpm@linux-foundation.org>
	 <alpine.LFD.0.999.0707241124220.3607@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christoph Lameter <clameter@sgi.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:42738 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750946AbXGYFJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 01:09:09 -0400
In-Reply-To: <alpine.LFD.0.999.0707241124220.3607@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-24 at 11:25 -0700, Linus Torvalds wrote:
> 
> On Tue, 24 Jul 2007, Andrew Morton wrote:
> > 
> > I guess this was the bug:
> 
> Looks very likely to me. Mike, Alexey, does this fix things for you?

I don't have very much runtime on it yet, but yes, it seems to have.

	-Mike

