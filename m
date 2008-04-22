From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [DCCP]: Convert do_gettimeofday() to getnstimeofday().
Date: Mon, 21 Apr 2008 19:45:26 -0700 (PDT)
Message-ID: <20080421.194526.101135578.davem@davemloft.net>
References: <20080421134844.GC12221@ghostprotocols.net>
	<20080421.142857.234288906.davem@davemloft.net>
	<20080422.114042.70459573.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org, dccp@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46924
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753392AbYDVCpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 22:45:24 -0400
In-Reply-To: <20080422.114042.70459573.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Tue, 22 Apr 2008 11:40:42 +0900 (JST)

> In article <20080421.142857.234288906.davem@davemloft.net> (at Mon, 21 Apr 2008 14:28:57 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > Thanks for reviewing, patch applied.
> 
> Sorry I have just realized set_normalized_timespec() (used in timespec_sub())
> is not exported, and link will fail because of it...
> 
> What should I/we do?  Send the patch to LKML as well?

I'll apply and push this change, thank you.
