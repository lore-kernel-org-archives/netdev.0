From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH/RFC net-next 0/4] net/sched: cls_flower: avoid false
 matching of truncated packets
Date: Mon, 1 May 2017 21:35:47 -0400
Message-ID: <c88b57d8-81a5-78e5-add6-33941f912d73@mojatatu.com>
References: <20170428120035.15984-1-simon.horman@netronome.com>
 <422d55da-f861-1bc6-983d-199fc383c113@mojatatu.com>
 <20170428131155.GA30329@vergenet.net>
 <2c14754a-f3f5-cece-2cd7-361948a00c22@mojatatu.com>
 <20170428141414.GA11256@vergenet.net>
 <0e993860-4dfd-3562-5ccb-c5ad24e5f970@mojatatu.com>
 <20170501103645.GC24399@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:38839 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750723AbdEBBfu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 21:35:50 -0400
Received: by mail-it0-f50.google.com with SMTP id e65so1535295ita.1
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 18:35:49 -0700 (PDT)
In-Reply-To: <20170501103645.GC24399@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-01 06:36 AM, Simon Horman wrote:
> On Sun, Apr 30, 2017 at 09:51:30AM -0400, Jamal Hadi Salim wrote:
>> On 17-04-28 10:14 AM, Simon Horman wrote:

[..]

>> minimal some flag should qualify it as "truncated".
>
> Would changing TCA_FLOWER_HEADER_PARSE_ERR_ACT to
> TCA_FLOWER_META_TRUNCATED help?
>

I think so - as long as you are able to recognize the truncated
vs real 0 port/type etc.

cheers,
jamal
