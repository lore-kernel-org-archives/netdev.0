From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: stmmac DT property snps,axi_all
Date: Fri, 9 Dec 2016 10:20:36 +0100
Message-ID: <dc145c32-cb67-4bcb-e8b7-059387d5a0ac@axis.com>
References: <51f8249e-bdb9-e3a7-5d82-7ac869316f0e@axis.com>
 <120aca00-02a8-3d88-7aad-a21d239aafb2@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:33008 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932595AbcLIJUj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Dec 2016 04:20:39 -0500
In-Reply-To: <120aca00-02a8-3d88-7aad-a21d239aafb2@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2016 02:36 PM, Alexandre Torgue wrote:
> Hi Niklas,
>
> On 12/05/2016 05:18 PM, Niklas Cassel wrote:
>> Hello Giuseppe
>>
>>
>> I'm trying to figure out what snps,axi_all is supposed to represent.
>>
>> It appears that the value is saved, but never used in the code.
>>
>> Looking at the register specification, I'm guessing that it represents
>> Address-Aligned Beats, but there is already the property snps,aal
>> for that.
>
> IMO, it is not useful. Indeed AXI_AAL is a read only bit (in AXI bus mode register) and reflects the aal bit in DMA bus register.
> As you know we use "snps,aal" to set aal bit in DMA bus register.
> So "snps,axi_all" entry seems useless. Let's see with Peppe.

Ok, I see. GMAC and GMAC4 is different here.

For GMAC4 AAL only exists in DMA_SYS_BUS_MODE.
It's not reflected anywhere else.

The code is correct in the driver.

If snps,axi_all is just created for a read-only register,
and it is currently never used in the code,
while we have snps,aal, which is correct and works,
I guess it should be ok to remove snps,axi_all.

I can cook up a patch.

>
> Regards
> Alex
>
>>
>>
>> Regards,
>> Niklas
>>
