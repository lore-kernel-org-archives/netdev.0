From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] be2net: fix disabling TX in be_close()
Date: Wed, 21 Aug 2013 18:48:43 +0400
Message-ID: <5214D34B.8080701@cogentembedded.com>
References: <1377080534-19509-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:51255 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294Ab3HUOsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 10:48:37 -0400
Received: by mail-la0-f48.google.com with SMTP id er20so417422lab.7
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 07:48:35 -0700 (PDT)
In-Reply-To: <1377080534-19509-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 21-08-2013 14:22, Sathya Perla wrote:

> commit fba875591 disabled TX in be_close() to protect be_xmit() from

    Please also specify that commit's summary line in parens.

> touching freed up queues in the AER recovery flow.
> But, TX must be disabled *before* cleaning up TX completions in the
> close() path, not after. This allows be_tx_compl_clean() to free up
> all TX-req skbs that were notified to the HW.

> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

WBR, Sergei
