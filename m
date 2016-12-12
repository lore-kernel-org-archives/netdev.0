From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac DT property snps,axi_all
Date: Mon, 12 Dec 2016 14:16:52 +0100
Message-ID: <a68542ac-9adf-ba3c-33cc-ce7d4faafecb@st.com>
References: <51f8249e-bdb9-e3a7-5d82-7ac869316f0e@axis.com>
 <120aca00-02a8-3d88-7aad-a21d239aafb2@st.com>
 <dc145c32-cb67-4bcb-e8b7-059387d5a0ac@axis.com>
 <e0362693-4ae9-b3d6-3955-c72df7a1b0c0@axis.com>
 <6c79e89f-52a2-3ac9-c976-6aa006e5ac38@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Alexandre Torgue <alexandre.torgue@st.com>,
        Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:49319 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750712AbcLLNQ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 08:16:58 -0500
In-Reply-To: <6c79e89f-52a2-3ac9-c976-6aa006e5ac38@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

On 12/9/2016 5:06 PM, Alexandre Torgue wrote:
> Hi Niklas
>
> On 12/09/2016 10:53 AM, Niklas Cassel wrote:
>> On 12/09/2016 10:20 AM, Niklas Cassel wrote:
>>> On 12/08/2016 02:36 PM, Alexandre Torgue wrote:
>>>> Hi Niklas,
>>>>
>>>> On 12/05/2016 05:18 PM, Niklas Cassel wrote:
>>>>> Hello Giuseppe
>>>>>
>>>>>
>>>>> I'm trying to figure out what snps,axi_all is supposed to represent.
>>>>>
>>>>> It appears that the value is saved, but never used in the code.
>>>>>
>>>>> Looking at the register specification, I'm guessing that it represents
>>>>> Address-Aligned Beats, but there is already the property snps,aal
>>>>> for that.
>>>> IMO, it is not useful. Indeed AXI_AAL is a read only bit (in AXI bus
>>>> mode register) and reflects the aal bit in DMA bus register.
>>>> As you know we use "snps,aal" to set aal bit in DMA bus register.
>>>> So "snps,axi_all" entry seems useless. Let's see with Peppe.
>>> Ok, I see. GMAC and GMAC4 is different here.
>>>
>>> For GMAC4 AAL only exists in DMA_SYS_BUS_MODE.
>>> It's not reflected anywhere else.
>>>
>>> The code is correct in the driver.
>>>
>>> If snps,axi_all is just created for a read-only register,
>>> and it is currently never used in the code,
>>> while we have snps,aal, which is correct and works,
>>> I guess it should be ok to remove snps,axi_all.
>>>
>>> I can cook up a patch.
>>>
>>
>> Here we go :)
>>
>> I will send it as a real patch once net-next reopens.
>
> Thanks ;). Just check with Peppe next week (as he added in the past this
> property).

Yes, we can conclude that the axi_all can be safely removed from DT, in
fact on all GMACs the AaL will be set via DMA_BUS_MODE register.

peppe
