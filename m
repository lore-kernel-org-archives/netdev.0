From: Christoph Hellwig <hch@infradead.org>
Subject: Re: smallish review of acx1xx-wireless-driver.patch
Date: Fri, 20 Oct 2006 08:07:02 +0100
Message-ID: <20061020070702.GA29871@infradead.org>
References: <20061020023704.GC5342@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, acx100-devel@lists.sourceforge.net,
	Andrew Morton <akpm@osdl.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Denis Vlasenko <vda@ilport.com.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:38298 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S2992527AbWJTHHI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 03:07:08 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
Content-Disposition: inline
In-Reply-To: <20061020023704.GC5342@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 20, 2006 at 06:37:04AM +0400, Alexey Dobriyan wrote:
> Main griefs:
> a) home-grown lock debugger (what can it do what lockdep can't?)
> b) lack of endian annotations.

I have a 95% patch for that.  let me dig it up again.  it depends on
a previous patch to kill the (huge) remainders of the old included
linux-wlan-ng derived wireless stack in the driver.

