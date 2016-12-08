From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: stmmac DT property snps,axi_all
Date: Thu, 8 Dec 2016 14:36:23 +0100
Message-ID: <120aca00-02a8-3d88-7aad-a21d239aafb2@st.com>
References: <51f8249e-bdb9-e3a7-5d82-7ac869316f0e@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:45301 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753230AbcLHNgz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 08:36:55 -0500
In-Reply-To: <51f8249e-bdb9-e3a7-5d82-7ac869316f0e@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Niklas,

On 12/05/2016 05:18 PM, Niklas Cassel wrote:
> Hello Giuseppe
>
>
> I'm trying to figure out what snps,axi_all is supposed to represent.
>
> It appears that the value is saved, but never used in the code.
>
> Looking at the register specification, I'm guessing that it represents
> Address-Aligned Beats, but there is already the property snps,aal
> for that.

IMO, it is not useful. Indeed AXI_AAL is a read only bit (in AXI bus 
mode register) and reflects the aal bit in DMA bus register.
As you know we use "snps,aal" to set aal bit in DMA bus register.
So "snps,axi_all" entry seems useless. Let's see with Peppe.

Regards
Alex

>
>
> Regards,
> Niklas
>
