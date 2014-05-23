From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: question: Any way to trigger DHCP renewal from kernel code?
Date: Thu, 22 May 2014 20:49:43 -0400
Message-ID: <537E9B27.8050800@gmail.com>
References: <c64a7b76572942fda9acffc25dd76c29@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Haiyang Zhang <haiyangz@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:41037 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbaEWAtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 20:49:46 -0400
Received: by mail-qc0-f173.google.com with SMTP id i8so7043792qcq.32
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 17:49:45 -0700 (PDT)
In-Reply-To: <c64a7b76572942fda9acffc25dd76c29@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2014 06:24 PM, Haiyang Zhang wrote:
> Hi,
> 
> Our synthetic network driver is notified when the Hyper-V host 
> resume from sleep/hibernation. We need to renew DHCP in this case.
> I'm looking for a way to trigger DHCP renewal from kernel mode 
> code.
> 
> Can anyone help me?

One idea:

Generate a udev event and a udev rule that triggers a renew when
event is received.

-vlad

> 
> Thanks,
> - Haiyang
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
