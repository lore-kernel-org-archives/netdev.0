From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RCU PATCH 00/14] Remove qdisc lock around ingress Qdisc
Date: Fri, 14 Mar 2014 03:45:51 -0400
Message-ID: <5322B3AF.3080004@mojatatu.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32> <53200588.5060805@mojatatu.com> <53208F11.8010304@gmail.com> <53216FE9.7090604@mojatatu.com> <5322AF88.60702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:47744 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755419AbaCNHqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 03:46:01 -0400
Received: by mail-wi0-f179.google.com with SMTP id f8so2187184wiw.0
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 00:46:00 -0700 (PDT)
In-Reply-To: <5322AF88.60702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/14 03:28, John Fastabend wrote:

> Ran the attached script and modified it to match UDP packets so I could
> use it with pktgen to hammer it a bit more. And changed it to add/delete
> filters with traffic while doing a watch on the filter and qdisc stats.
> No oops, splats or anything else crazy.
>

Most excellent;->
Please add my Acked-by when you send the next series.

> I need to get some sleep now though so the performance numbers will have
> to wait for tomorrow.

NP. Not expecting to see a regression (likely an improvement like you
said).

cheers,
jamal
