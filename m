From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 4/4] net_sched: gred: actually perform idling in WRED
 mode
Date: Thu, 13 Sep 2012 16:37:54 -0400
Message-ID: <50524422.8000804@mojatatu.com>
References: <1347549755-19438-1-git-send-email-david.ward@ll.mit.edu> <1347549755-19438-4-git-send-email-david.ward@ll.mit.edu> <50522106.40404@mojatatu.com> <50523632.60703@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bruce Osler <brosler@cisco.com>,
	Cyril Chemparathy <cyril@ti.com>
To: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:37912 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756478Ab2IMUh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:37:59 -0400
Received: by vbbff1 with SMTP id ff1so4013270vbb.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 13:37:58 -0700 (PDT)
In-Reply-To: <50523632.60703@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-09-13 03:38 PM, Ward, David - 0663 - MITLL wrote:
> Before applying this patch, the average queue size (as seen with "tc 
> -s qdisc") remained constant forever after I stopped sending any 
> packets through the interface -- it didn't taper off as you would 
> expect.  After the patch, the average queue size will now taper off if 
> packets are not being sent.
>


That makes sense. thanks

cheers,
jamal
