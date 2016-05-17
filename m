From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net: also make sch_handle_egress() drop monitor
 ready
Date: Tue, 17 May 2016 07:55:06 -0400
Message-ID: <573B069A.8070506@mojatatu.com>
References: <94bae5636d86c039a0cfee3aa4876fc7bcde2eef.1463347152.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35429 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240AbcEQLzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 07:55:09 -0400
Received: by mail-io0-f193.google.com with SMTP id i75so2901926ioa.2
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 04:55:08 -0700 (PDT)
In-Reply-To: <94bae5636d86c039a0cfee3aa4876fc7bcde2eef.1463347152.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-15 05:28 PM, Daniel Borkmann wrote:
> Follow-up for 8a3a4c6e7b34 ("net: make sch_handle_ingress() drop
> monitor ready") to also make the egress side drop monitor ready.
>
> Also here only TC_ACT_SHOT is a clear indication that something
> went wrong. Hence don't provide false positives to drop monitors
> such as 'perf record -e skb:kfree_skb ...'.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
