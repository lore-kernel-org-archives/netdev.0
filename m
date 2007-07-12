From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 1/5] try parent numa_node at first before using default
Date: Thu, 12 Jul 2007 04:47:45 +0200
Message-ID: <46959651.1050400@s5r6.in-berlin.de>
References: <200707101641.17672.yinghai.lu@sun.com> <200707101652.31378.yinghai.lu@sun.com> <4694B702.2050507@s5r6.in-berlin.de> <20070711210833.GA22745@kroah.com> <46954B92.8000407@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <ak@suse.de>, rientjes@google.com,
	Christoph Lameter <clameter@sgi.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Yinghai.Lu@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:48658 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934458AbXGLCtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 22:49:07 -0400
In-Reply-To: <46954B92.8000407@sun.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yinghai Lu wrote:
> original default is -1, and this patch just try to use parent's node as
> default.

But in many cases, the patch does so at a time when the parent is not
yet known.
-- 
Stefan Richter
-=====-=-=== -=== -==--
http://arcgraph.de/sr/
