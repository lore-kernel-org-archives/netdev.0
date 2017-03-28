From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH net-next 0/2] net: stmmac: multiple queue fixes
Date: Tue, 28 Mar 2017 13:23:21 +0200
Message-ID: <8eed041a-a67e-3d18-e1a7-04d53f03737e@axis.com>
References: <cover.1490375512.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <clabbe.montjoie@gmail.com>, <thierry.reding@gmail.com>,
        <sergei.shtylyov@cogentembedded.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:35893 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932248AbdC1LfG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 07:35:06 -0400
In-Reply-To: <cover.1490375512.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2017 06:16 PM, Joao Pinto wrote:
> This patch set contains two fixes for problems I detected when ran the driver
> in single queue mode.
> 
> Please test in your setups to check if you get better results.
> 
> Joao Pinto (2):
>   net: stmmac: fix netdev release
>   net: stmmac: fix number of tx queues in stmmac_poll
> 
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 18 +++++++++++-------
>  1 file changed, 11 insertions(+), 7 deletions(-)
> 

Hello Joao,

I think that it would be helpful if these commit messages were a
little more elaborate.
Both of these commit messages just say "fixes kernel crash".
Please include the relevant part of the stack trace so that others
will know if the bug you are fixing is the same as theirs.

Regards,
Niklas
