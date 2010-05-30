From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Patch]8139too: remove unnecessary cast of ioread32()'s return
 value
Date: Sun, 30 May 2010 19:24:18 -0400
Message-ID: <4C02F3A2.90100@garzik.org>
References: <20100530122213.GB1146@host-a-55.ustcsz.edu.cn>	<4C02A1F7.6030701@garzik.org> <20100530.153451.193700815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:45800 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab0E3XYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 19:24:21 -0400
Received: by gwaa12 with SMTP id a12so2285236gwa.19
        for <netdev@vger.kernel.org>; Sun, 30 May 2010 16:24:20 -0700 (PDT)
In-Reply-To: <20100530.153451.193700815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2010 06:34 PM, David Miller wrote:
> From: Jeff Garzik<jeff@garzik.org>
> Date: Sun, 30 May 2010 13:35:51 -0400
>
>> Have you verified this matches all architectures definition of
>> readl()?

> And if it doesn't match, that's an arch bug which should be fixed and
> in any event there is only one possibility of a non-match and that is
> if the routine returns "unsigned long"

That was the genesis of the question.  Some arches still use unsigned long.

	Jeff



