From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fake rtable dst patch applied but kernel keeps panicing
Date: Thu, 19 Apr 2012 10:14:16 +0200
Message-ID: <1334823256.2395.2.camel@edumazet-glaptop>
References: <4F8E9291.9000607@navynet.it>
	 <1334745072.2472.110.camel@edumazet-glaptop>  <4F8FC66F.90703@navynet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Massimo Cetra <ctrix+debianbugs@navynet.it>,
	netdev@vger.kernel.org, peter.huangpeng@huawei.com
To: Massimo Cetra <mcetra@navynet.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36952 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab2DSIOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 04:14:20 -0400
Received: by bkcik5 with SMTP id ik5so6100518bkc.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 01:14:19 -0700 (PDT)
In-Reply-To: <4F8FC66F.90703@navynet.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 10:01 +0200, Massimo Cetra wrote:
> On 18/04/2012 12:31, Eric Dumazet wrote:
> >
> > Seems a different issue, skb->nf_bridge seems to be NULL
> >
> 
> This is another trace of another panic.
> I hope it may be useful.
> Please notice that it is not related to adding/removing br interfaces or 
> tun/vic interfaces from a bridge set.
> It happened suddenly during a normal workload.
> 
> When were those bridge-related bugs introduced ?
> What's the latest release that seems to work ?
> I'm asking so that i can restore some servers to a proper workload.
> 
> 
> Massimo

Maybe you should try latest kernel, because we fixed some bugs lately.
