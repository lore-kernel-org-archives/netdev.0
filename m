From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 4/4] net_sched: gred: actually perform idling in WRED
 mode
Date: Thu, 13 Sep 2012 14:08:06 -0400
Message-ID: <50522106.40404@mojatatu.com>
References: <1347549755-19438-1-git-send-email-david.ward@ll.mit.edu> <1347549755-19438-4-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bruce Osler <brosler@cisco.com>,
	Cyril Chemparathy <cyril@ti.com>
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:51139 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755119Ab2IMSIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 14:08:10 -0400
Received: by vbbff1 with SMTP id ff1so3805724vbb.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 11:08:09 -0700 (PDT)
In-Reply-To: <1347549755-19438-4-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-09-13 11:22 AM, David Ward wrote:
> gred_dequeue() and gred_drop() do not seem to get called when the
> queue is empty, meaning that we never start idling while in WRED
> mode. And since qidlestart is not stored by gred_store_wred_set(),
> we would never stop idling while in WRED mode if we ever started.
> This messes up the average queue size calculation that influences
> packet marking/dropping behavior.
>
> Now, we start WRED mode idling as we are removing the last packet
> from the queue. Also we now actually stop WRED mode idling when we
> are enqueuing a packet.
>
> Cc: Bruce Osler <brosler@cisco.com>
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

This is one is not so obvious. Iam assuming you vetted it via some tests.
In which case:
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
