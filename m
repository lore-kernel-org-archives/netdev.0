From: Patrice Chotard <patrice.chotard@st.com>
Subject: Re: [PATCH 18/19] stmmac: dwmac-sti: Remove obsolete STi platforms
Date: Tue, 18 Oct 2016 10:05:10 +0200
Message-ID: <dcbb8065-b272-0a2f-8efb-c55217712caf@st.com>
References: <1473859677-9231-1-git-send-email-peter.griffin@linaro.org>
 <1473859677-9231-19-git-send-email-peter.griffin@linaro.org>
 <20160923151142.GG9176@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>,
        <linux-kernel@vger.kernel.org>, <kernel@stlinux.com>,
        <devicetree@vger.kernel.org>, <lee.jones@linaro.org>,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>
To: Rob Herring <robh@kernel.org>,
        Peter Griffin <peter.griffin@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:52923 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752216AbcJRIFv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 04:05:51 -0400
In-Reply-To: <20160923151142.GG9176@rob-hp-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/23/2016 05:11 PM, Rob Herring wrote:
> On Wed, Sep 14, 2016 at 02:27:56PM +0100, Peter Griffin wrote:
>> This patch removes support for STiH415/6 SoC's from the
>> dwmac-sti driver and dt binding doc, as support for these
>> platforms is being removed from the kernel. It also removes
>> STiD127 related code, which has never actually been supported
>> upstream.
>>
>> Signed-off-by: Peter Griffin <peter.griffin@linaro.org>
>> Cc: <peppe.cavallaro@st.com>
>> Cc: <alexandre.torgue@st.com>
>> Cc: <netdev@vger.kernel.org>
>> ---
>>  .../devicetree/bindings/net/sti-dwmac.txt          |  3 +-
> 
> Acked-by: Rob Herring <robh@kernel.org>


Applied on sti-dt-for-4.10 branch

Thanks 

> 
>>  drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    | 37 ----------------------
>>  2 files changed, 1 insertion(+), 39 deletions(-)
