From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 2.6.27-rc9 QGLE make unsupported page size explicit
 compile failure
Date: Mon, 13 Oct 2008 22:56:14 -0700 (PDT)
Message-ID: <20081013.225614.55382681.davem@davemloft.net>
References: <20081014021902.GY25780@parisc-linux.org>
	<20081013.193153.203217396.davem@davemloft.net>
	<20081014025329.GA25397@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matthew@wil.cx, grundler@parisc-linux.org, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-ia64@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <20081014025329.GA25397@susedev.qlogic.org>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 13 Oct 2008 19:53:29 -0700

> My explanation might not have been very good.  What I was trying to say
> is that the macro in question determines the size of a scatter/gathter
> list that is external to the TX descriptor.  The size is based on
> MAX_SKB_FRAGS and PAGE_SIZE.  When PAGE_SIZE is larger than 8k I don't
> need the external scatter/gather list because all frags will fit in the
> native TX descriptor.

Yes, it all makes sense now, thanks Ron.

Patch applied.
