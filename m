From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH] stmicro: rename it to dwc to improve future development
Date: Tue, 17 Jan 2017 10:16:45 +0000
Message-ID: <5ef1b502-f113-9b94-c1ae-dc60a9bdf6fb@synopsys.com>
References: <0f5b325a9c8d9e5b6c95f90d833278cfb8f77606.1484571696.git.jpinto@synopsys.com>
 <20170116.135850.618334211623485798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:41874 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751157AbdAQKRK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 05:17:10 -0500
In-Reply-To: <20170116.135850.618334211623485798.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Às 6:58 PM de 1/16/2017, David Miller escreveu:
> From: Joao Pinto <Joao.Pinto@synopsys.com>
> Date: Mon, 16 Jan 2017 13:26:31 +0000
> 
>> The goal of this patch is to create an oficial Designware Ethernet place
>> to deploy new drivers based on this family of IPs. stmmac was left
>> untouched since it is a designware based driver. New ethernet designware
>> IP based drivers should be placed in this place, improving code organization
>> and it becomes clear to the kernel user the purpose and scope of each driver.
>>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> 
> Sorry, I am not applying this.
> 
> This would mean that every single -stable backport of a fix to this
> driver would require fixing up the directory and/or file name of every
> single change without any exception.
> 
> This is an unreasonable burdon to put upon me, and every single person
> who has to backport bug fixes into older releases of the kernel.
> 
> Please stop submitting this rename change.  It is fine to leave the
> driver with the stmmac name, and there is zero user benefit to the
> rename and only negatives for people who have to work on backports.
> 
> I saw no agreement reached between yourself and anyone who voiced
> opposition to this driver rename.  Therefore it was entirely
> inappropriate for you to resubmit this change again.

Just submited an alternative to the initial rename patch with 0 impact to
STMicroelectronics, so I tried to find a better solution.

I respect your decision.

A new Designware Ethernet IP title driver is being developed at this moment.
Could you please suggest a suitable place to put it, in order to avoid problems
when we reach the upstream phase?

Thanks.

> 
> I heard very clearly your argument that you would help with the problem
> with the backports, but that is a completely empty gesture.  Here's why.
> 
> You cannot help with the problem, nor can any other developer working
> on this driver.  People all over the world are going to want to
> backport this patch or that, and I myself work in my own little
> routine and can't depend on having to have a back and forth with you
> over and over again for every single fix to this driver I decide is
> reasonable for a -stable backport.
> 
