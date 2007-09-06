From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Subject: Re: net-26.24 broken with XFRM off
Date: Thu, 06 Sep 2007 19:01:20 +0900 (JST)
Message-ID: <20070906.190120.432840050.takamiya@po.ntts.co.jp>
References: <46DFAB7F.7060406@chelsio.com>
	<20070906101326.34a81abb.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, usagi-core@linux-ipv6.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.ics.ntts.co.jp ([202.32.24.42]:39640 "EHLO
	mail2.ics.ntts.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbXIFK1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 06:27:18 -0400
In-Reply-To: <20070906101326.34a81abb.dada1@cosmosbay.com>
	<20070903193711.6A1D.NAKAM@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

>> Thu, 6 Sep 2007 10:13:26 +0200
>> [Subject: Re: net-26.24 broken with XFRM off]
>> Eric Dumazet <dada1@cosmosbay.com> wrote...

> Hi Divy
> 
> I believe this problem is known.
> 
> Please check http://marc.info/?l=linux-netdev&m=118881627028135&w=2 

  I'm sorry not to check more precisely.

  As Eric said, this issue should be fixed by the patch attached in
  the following mail.

  Regards,

>> Mon, 03 Sep 2007 19:43:51 +0900
>> [Subject: Re: [-mm patch] IPV6 must select XFRM]
>> Masahide NAKAMURA <nakam@linux-ipv6.org> wrote...

> Thank you for catching this. the issue is caused with patch
> "[IPV6] XFRM: Fix connected socket to use transformation."
> which I sent to netdev.
> (a85d5450ddeb959bdf9e4603f9c06e9d79217cfa on net-2.6.24).
> 
> I'd prefer to modify the original patch to use "ifdef CONFIG_XFRM"
> than changing kernel config depends. Does it make sense?
> 
> Please review the attached patch.
> 
> -- 
> Masahide NAKAMURA
--
Noriaki TAKAMIYA
