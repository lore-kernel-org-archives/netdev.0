From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Tue, 24 Jul 2007 11:25:22 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0707241124220.3607@woody.linux-foundation.org>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
 <20070723183839.GA5874@martell.zuzino.mipt.ru> <20070723190152.GA5755@martell.zuzino.mipt.ru>
 <20070723132431.42afbae8.akpm@linux-foundation.org> <1185271269.6479.7.camel@Homer.simpson.net>
 <20070724092839.f0556948.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Mike Galbraith <efault@gmx.de>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christoph Lameter <clameter@sgi.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42145 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750801AbXGXS0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 14:26:02 -0400
In-Reply-To: <20070724092839.f0556948.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 24 Jul 2007, Andrew Morton wrote:
> 
> I guess this was the bug:

Looks very likely to me. Mike, Alexey, does this fix things for you?

		Linus
