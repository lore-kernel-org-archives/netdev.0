From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] sh_eth: fix unhandled RFE interrupt
Date: Mon, 24 Jun 2013 15:07:49 +0400
Message-ID: <51C82885.8030607@cogentembedded.com>
References: <201306210112.22352.sergei.shtylyov@cogentembedded.com> <20130624.001044.2036651955086655996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:61541 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979Ab3FXLHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 07:07:53 -0400
Received: by mail-lb0-f181.google.com with SMTP id w10so409964lbi.40
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 04:07:52 -0700 (PDT)
In-Reply-To: <20130624.001044.2036651955086655996.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 24-06-2013 11:10, David Miller wrote:

>> EESR.RFE (receive FIFO overflow) interrupt is enabled by the driver on all SoCs
>> and sh_eth_error() handles it but it's not present in any initializer/assignment
>> of the 'eesr_err_check' field of 'struct sh_eth_cpu_data'. This leads to that
>> interrupt not being handled and cleared, and finally to disabling IRQ and the
>> driver being non-functional.

>> Modify DEFAULT_EESR_ERR_CHECK macro and all explicit initializers of the above
>> mentioned field to contain the EESR.RFE bit. Remove useless backslashes from the
>> initializers, while at it.

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> Applied to 'net'.

    Queue it for -stable please, the bug goes back to the very start of 
the driver development, it seems...

WBR, Sergei
