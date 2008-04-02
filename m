From: David Miller <davem@davemloft.net>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Wed, 02 Apr 2008 11:44:41 -0700 (PDT)
Message-ID: <20080402.114441.78726196.davem@davemloft.net>
References: <20080402.012406.246863209.davem@davemloft.net>
	<20080402175857.959A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080402195428.95A3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, csnook@redhat.com,
	davej@codemonkey.org.uk, nickpiggin@yahoo.com.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mchan@broadcom.com
To: kosaki.motohiro@jp.fujitsu.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760738AbYDBSpA@vger.kernel.org>
In-Reply-To: <20080402195428.95A3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 02 Apr 2008 19:56:05 +0900

> 
> > ---------------------------------------------------------------------
> > We get rather a lot of reports of page allocation warnings coming out of
> > tg3.  But this driver is know to handle them properly so let's suppress
> > them.
> 
> BTW:
> other person's tg3 allocation failure bug report.
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=9771

Yes, I know about it.  It will occur for any device
which must use linear RX buffers and supports
>PAGE_SIZE MTUs.

But modern chips are going to support segmentation of
receive packets into multiple individual pages and
therefore not have this order>0 page allocation
requirement.

That is my point.
