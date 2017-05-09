From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Requirements for a shutdown function?
Date: Tue, 9 May 2017 13:51:28 -0500
Message-ID: <f995d5b3-2a5c-df08-3915-f77ab9203844@codeaurora.org>
References: <49bee65f-2ea8-1787-9642-659a967df8f0@codeaurora.org>
 <1721db9b-ed60-4556-9aac-81f17e2c1849@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:41860 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751471AbdEISva (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 14:51:30 -0400
In-Reply-To: <1721db9b-ed60-4556-9aac-81f17e2c1849@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2017 01:46 PM, Florian Fainelli wrote:
> A good test case for exercising a .shutdown() function is kexec'ing a
> new kernel for instance.

I tried that.  I run iperf in one window while launching kexec in another.
Even without a shutdown function, network traffic appear to halt on its own
and the kexec succeeds.

Is it possible that the network stack detects a kexec and automatically
stops all network devices?

> You should put your HW in a state where it won't be doing DMA, or have
> any adverse side effects to the system, putting it in a low power state
> is also a good approach.

My in-house driver stops the RX and TX queues.  I'm guessing that's good
enough, but I don't have a failing test case to prove it.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
