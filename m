From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH -next] qed: Remove useless set memory to zero use memset()
Date: Tue, 18 Oct 2016 20:20:41 +0300
Message-ID: <aa9877bc-850a-fa2d-72e7-6d7a5b37ac55@cogentembedded.com>
References: <1476806090-4456-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, everest-linux-l2@qlogic.com,
        netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33576 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934797AbcJRRUp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 13:20:45 -0400
Received: by mail-lf0-f50.google.com with SMTP id x79so283243lff.0
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 10:20:44 -0700 (PDT)
In-Reply-To: <1476806090-4456-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2016 06:54 PM, Wei Yongjun wrote:

> From: Wei Yongjun <weiyongjun1@huawei.com>
>
> The memory return by kzalloc() has already be set to zero, so

    Returned?

> remove useless memset(0).
>
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
[...]

MBR, Sergei
