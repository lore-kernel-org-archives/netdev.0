From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net 0/4] net/sched: Fix a system panic when deleting
 filters
Date: Mon, 16 Oct 2017 07:06:04 -0400
Message-ID: <556e3159-78ae-d07b-928e-37d99d380a3d@mojatatu.com>
References: <1508142702-3312-1-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lucasb@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net
To: Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:43488 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752075AbdJPLGL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 07:06:11 -0400
Received: by mail-it0-f52.google.com with SMTP id k70so2707553itk.0
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 04:06:11 -0700 (PDT)
In-Reply-To: <1508142702-3312-1-git-send-email-chrism@mellanox.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Chris,

On 17-10-16 04:31 AM, Chris Mi wrote:
> If some filters share the same action, when deleting these filters,
> system may panic. This patchset fixes this issue. And the test case
> finding this issue is also integrated into tc test suite of selftests.
>

I think this would read better if re-worded as:
---
If some filters share the same action, when deleting these filters,
it is possible to create a system panic. This is because deletions
could be manipulated by many RCU callbacks at the same time.
This patch set fixes these issues.
To reproduce the issue run selftests in patch 3 and 4.
To test if the issue was fixed, apply patches 1 and 2 and
then repeat the tests.
------

Other than that all look good to me and:

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
