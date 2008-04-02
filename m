From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Wed, 02 Apr 2008 12:12:06 -0800
Message-ID: <1207167128.5311.5.camel@dell>
References: <20080402.012406.246863209.davem@davemloft.net>
 <20080402175857.959A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
 <20080402195428.95A3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
 <20080402.114441.78726196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org,
	csnook@redhat.com, davej@codemonkey.org.uk,
	nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2337 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755304AbYDBTYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 15:24:14 -0400
In-Reply-To: <20080402.114441.78726196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-04-02 at 11:44 -0700, David Miller wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Wed, 02 Apr 2008 19:56:05 +0900
>
> > BTW:
> > other person's tg3 allocation failure bug report.
> > 
> > http://bugzilla.kernel.org/show_bug.cgi?id=9771
> 
> Yes, I know about it.  It will occur for any device
> which must use linear RX buffers and supports
> >PAGE_SIZE MTUs.
> 
> But modern chips are going to support segmentation of
> receive packets into multiple individual pages and
> therefore not have this order>0 page allocation
> requirement.

tg3 hardware has a jumbo rx ring that can accommodate non-linear SKBs.
Matt is working on some patches to add this feature.

