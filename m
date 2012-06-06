From: Grant Edwards <grant.b.edwards@gmail.com>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Wed, 6 Jun 2012 20:22:06 +0000 (UTC)
Message-ID: <jqoe5d$fs3$1@dough.gmane.org>
References: <jqo7op$t6f$1@dough.gmane.org>
 <1339008142.26966.40.camel@edumazet-glaptop> <jqo9a6$ah6$1@dough.gmane.org>
 <20120606.120247.1618312724057709285.davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:48396 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257Ab2FFUWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 16:22:21 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1ScMkE-0003CC-4B
	for netdev@vger.kernel.org; Wed, 06 Jun 2012 22:22:18 +0200
Received: from dsl.comtrol.com ([64.122.56.22])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 22:22:18 +0200
Received: from grant.b.edwards by dsl.comtrol.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 22:22:18 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-06-06, David Miller <davem@davemloft.net> wrote:
> From: Grant Edwards <grant.b.edwards@gmail.com>
> Date: Wed, 6 Jun 2012 18:59:19 +0000 (UTC)
>
>> At the time it was written (probably 10+ years ago) it was relying on
>> the documented API for alloc_skb() that stated alloc_skb() either
>> returned an sk_buff of the requested size or it failed.
>
> It was never a formal API that we would only allocate 'size'
> amount of tailroom.

Well, somebody forgot to tell whoever wrote the man page for
alloc_skb().  :)

-- 
Grant Edwards               grant.b.edwards        Yow! I'm ZIPPY the PINHEAD
                                  at               and I'm totally committed
                              gmail.com            to the festive mode.
