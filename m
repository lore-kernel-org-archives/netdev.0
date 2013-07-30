From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: r8a7790: Handle the RFE (Receive FIFO overflow
 Error) interrupt
Date: Tue, 30 Jul 2013 18:47:37 +0400
Message-ID: <51F7D209.7040501@cogentembedded.com>
References: <1375142928-17769-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <51F7CADE.5070801@cogentembedded.com> <4760883.hI1JN8gopV@avalon>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:60888 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405Ab3G3Orh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 10:47:37 -0400
Received: by mail-lb0-f179.google.com with SMTP id v1so1404159lbd.10
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 07:47:36 -0700 (PDT)
In-Reply-To: <4760883.hI1JN8gopV@avalon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 30-07-2013 18:20, Laurent Pinchart wrote:

>>> The RFE interrupt is enabled for the r8a7790 but isn't handled,
>>> resulting in the interrupts core noticing unhandled interrupts, and
>>> eventually disabling the ethernet IRQ.

>>> Fix it by adding RFE to the bitmask of error interrupts to be handled
>>> for r8a7790.

>> So, Simon hasn't synced his patch to my late bug fix in 3.10... Did this
>> patch help you with your NFS boot issue, Laurent?

> Yes, it fixes the "disabling interrupt, nobody cared" problem. I still have
> intermittent NFS issues, but at least I can now boot.

    I was somewhat thrown off by the Rx FIFO overflow messages appearing before
the "nobody cared", so I thought that must be another unhandled interrupt.

WBR, Sergei
