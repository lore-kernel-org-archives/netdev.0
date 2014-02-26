From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCHv3 1/2] net: stmmac: Add SOCFPGA glue driver
Date: Wed, 26 Feb 2014 10:44:33 +0100
Message-ID: <530DB781.9050901@st.com>
References: <1392061697-20193-1-git-send-email-dinguyen@altera.com> <20140212.193539.38124529344029793.davem@davemloft.net> <52FC4B0A.4010406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<vbridgers2013@gmail.com>
To: Dinh Nguyen <dinh.linux@gmail.com>,
	David Miller <davem@davemloft.net>, <dinguyen@altera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog125.obsmtp.com ([207.126.144.159]:33287 "EHLO
	eu1sys200aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751448AbaBZKGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 05:06:08 -0500
In-Reply-To: <52FC4B0A.4010406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/13/2014 5:33 AM, Dinh Nguyen wrote:
>
> On 2/12/14 6:35 PM, David Miller wrote:
>> From: <dinguyen@altera.com>
>> Date: Mon, 10 Feb 2014 13:48:16 -0600
>>
>>> From: Dinh Nguyen <dinguyen@altera.com>
>>>
>>> Like the STi series SOCs, Altera's SOCFPGA also needs a glue layer on top of the
>>> Synopsys gmac IP.
>>>
>>> This patch adds the platform driver for the glue layer which configures the IP
>>> before the generic STMMAC driver takes over.
>>>
>>> Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
>>> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>>> Cc: Rob Herring <robh+dt@kernel.org>
>>> Cc: Pawel Moll <pawel.moll@arm.com>
>>> Cc: Mark Rutland <mark.rutland@arm.com>
>>> Cc: Ian Campbell <ijc+devicetree@hellion.org.uk>
>>> Cc: Kumar Gala <galak@codeaurora.org>
>>> Cc: Vince Bridgers <vbridgers2013@gmail.com>
>>> ---
>>> v3: Remove stray empty line at end of dwmac-socfpga.c.
>>> v2: Use the dwmac-sti as an example for a glue layer and split patch up
>>> to have dts as a separate patch. Also cc dts maintainers since there is
>>> a new binding.
>> The second patch for the DTS update doesn't apply cleanly at all to
>> mainline.
> Yes, I'm planning to take the DTS bindings patch through arm-soc/next-dt
> tree, so that is where patch 2 is based on.
>>
>> Why don't you push both of these patches through whatever tree that
>> file is maintained under.  You can add my ack:
> I'm not sure if Peppe has a tree, but it should go into his tree
> if there is one. If not, can you apply patch 1 to your tree?

Hello

I have not own tree but I am using net.git and net-next to do my patches
and experiments.

I ask you to keep these patches aligned to net-next.

Also I ask you to review the glue-layer that is not in-line with what
have been currently added for dwmac-sti and dwmac-sunxi.c.

BR
Peppe


>>
>> Acked-by: David S. Miller <davem@davemloft.net>
> Thanks,
> Dinh
>
