From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: Performance in stmmac
Date: Mon, 13 Feb 2017 13:58:08 +0100
Message-ID: <67f5c073-bd38-7dbf-37e6-2eeb3039e83d@st.com>
References: <1d4da3b4-d798-e55a-3988-647adbfd8413@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>, <niklas.cassel@axis.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:38779 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751604AbdBMM6Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 07:58:16 -0500
In-Reply-To: <1d4da3b4-d798-e55a-3988-647adbfd8413@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joao

On 2/7/2017 8:33 PM, Joao Pinto wrote:
> I am seeing tx being performed in all queues, but rx is just being routed to
> queue 0. The reason why only queue 0 is processing the packets is because I am
> using priority tagged routing for now and iperf is not capable of producing
> priority tagged traffic.

I wonder if you tried the multi-queue channels & AV/B stack.

Regards
Peppe
