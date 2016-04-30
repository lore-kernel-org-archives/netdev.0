From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next] ifstat: move to new RTM_GETSTATS api
Date: Sat, 30 Apr 2016 08:15:13 -0700
Message-ID: <5724CC01.3030203@cumulusnetworks.com>
References: <1461998511-24193-1-git-send-email-roopa@cumulusnetworks.com> <57248720.8060001@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, nikolay@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33768 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbcD3PPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 11:15:16 -0400
Received: by mail-pf0-f179.google.com with SMTP id 206so60779669pfu.0
        for <netdev@vger.kernel.org>; Sat, 30 Apr 2016 08:15:16 -0700 (PDT)
In-Reply-To: <57248720.8060001@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/30/16, 3:21 AM, Jamal Hadi Salim wrote:
> On 16-04-30 02:41 AM, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch modifies ifstat to use the new RTM_GETSTATS api
>> to query stats from the kernel. In the process this also
>> moves ifstat to use 64 bit stats.
>
> Breaks old kernels? May need to keep backward compat of
> RTM_NEWLINK and even new main struct for GETSTATS.
yes, i was wondering about that. v2 coming. If GETSTATS fails, I will fallback to RTM_NEWLINK.

thanks!
