From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 net-next] ifstat: move to new RTM_GETSTATS api
Date: Sat, 30 Apr 2016 06:21:20 -0400
Message-ID: <57248720.8060001@mojatatu.com>
References: <1461998511-24193-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35069 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbcD3KVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 06:21:31 -0400
Received: by mail-qk0-f181.google.com with SMTP id q76so49390580qke.2
        for <netdev@vger.kernel.org>; Sat, 30 Apr 2016 03:21:30 -0700 (PDT)
In-Reply-To: <1461998511-24193-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-04-30 02:41 AM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch modifies ifstat to use the new RTM_GETSTATS api
> to query stats from the kernel. In the process this also
> moves ifstat to use 64 bit stats.

Breaks old kernels? May need to keep backward compat of
RTM_NEWLINK and even new main struct for GETSTATS.

cheers,
jamal
