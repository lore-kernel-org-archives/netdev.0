From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: Synopsys Ethernet QoS
Date: Fri, 9 Dec 2016 15:54:00 +0000
Message-ID: <f5029f0c-1a74-7b24-327e-ab1dce020954@synopsys.com>
References: <2df7a6dd-1128-d1d6-bf61-891f76cf7200@synopsys.com>
 <20161209.103327.1742213347114742435.davem@davemloft.net>
 <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
 <20161209.104152.1969880574279771010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <lars.persson@axis.com>,
        <rabin.vincent@axis.com>, <netdev@vger.kernel.org>,
        <andy.shevchenko@gmail.com>, <CARLOS.PALMINHA@synopsys.com>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:60972 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933614AbcLIPyF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 10:54:05 -0500
In-Reply-To: <20161209.104152.1969880574279771010.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 3:41 PM de 12/9/2016, David Miller escreveu:
> From: Joao Pinto <Joao.Pinto@synopsys.com>
> Date: Fri, 9 Dec 2016 15:36:38 +0000
> 
>> Of course, I started a general discussion about the subject and
>> those were the conclusions, but I would like to know if you as the
>> subsystem maintainer also support the approach or have any
>> suggestion.
> 
> Generally, I support whatever the interested parties agree to.
> 
> But one thing I am against is changing the driver name for existing
> users.  If an existing chip is supported by the stmmac driver for
> existing users, they should still continue to use the "stmmac" driver.
> 
> Therefore, if consolidation changes the driver module name for
> existing users, then that is not a good plan at all.
> 

Of course, 100% with you! Retro-compatibility for existing drivers is a must
have. The consolidation is going to be done with extreme careful.

Joao
