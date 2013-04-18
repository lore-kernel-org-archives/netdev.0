From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] pkt_sched: fix error return code in fw_change_attrs()
Date: Thu, 18 Apr 2013 09:23:30 -0400
Message-ID: <516FF3D2.7070402@mojatatu.com>
References: <CAPgLHd-cDj8j3tKofRMwJ8GE39LkO8ZvtTJ34aSFDSHO+7GjnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f178.google.com ([209.85.210.178]:63518 "EHLO
	mail-ia0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755489Ab3DRNXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 09:23:40 -0400
Received: by mail-ia0-f178.google.com with SMTP id w21so2412714iac.23
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 06:23:39 -0700 (PDT)
In-Reply-To: <CAPgLHd-cDj8j3tKofRMwJ8GE39LkO8ZvtTJ34aSFDSHO+7GjnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-04-17 10:49 PM, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> Fix to return -EINVAL when tb[TCA_FW_MASK] is set and head->mask != 0xFFFFFFFF
> instead of 0 (ifdef CONFIG_NET_CLS_IND and tb[TCA_FW_INDEV]), as done elsewhere
> in this function.
>
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>


Makes sense.  I think i would have said something like:
"dont use the err code from tcf_change_indev() in case it succeeds to 
report TCA_FW_MASK errors"

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
