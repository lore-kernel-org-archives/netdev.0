From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fake rtable dst patch applied but kernel keeps panicing
Date: Fri, 20 Apr 2012 15:22:47 +0200
Message-ID: <1334928167.2395.232.camel@edumazet-glaptop>
References: <4F8E9291.9000607@navynet.it>
	 <1334745072.2472.110.camel@edumazet-glaptop>  <4F8FC66F.90703@navynet.it>
	 <1334823256.2395.2.camel@edumazet-glaptop>
	 <1334825108.2395.28.camel@edumazet-glaptop>  <4F913429.2040705@navynet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.huangpeng@huawei.com
To: Massimo Cetra <ctrix+debianbugs@navynet.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43497 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756215Ab2DTNWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 09:22:52 -0400
Received: by bkcik5 with SMTP id ik5so7182307bkc.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 06:22:51 -0700 (PDT)
In-Reply-To: <4F913429.2040705@navynet.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-20 at 12:02 +0200, Massimo Cetra wrote:

> 
> i applied this patch and Peters last patch to a 3.3.2 kernel.
> The result was a bit disappointing because the step was backwards.
> 
> Locally, from the same machine, i could ping each IP of each tun 
> interface used by any virtual server.
> 
>  From the LAN such addresses were not pingable while the ip address of 
> the bridge was reachable.
> 
> Max

I dont know, this code is crap and should be fixed.

This nf_bridge_unshare() is obviously buggy as hell.
