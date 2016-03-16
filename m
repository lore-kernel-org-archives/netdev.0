From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc911x: convert pxa dma to dmaengine
Date: Tue, 15 Mar 2016 22:57:09 -0400 (EDT)
Message-ID: <20160315.225709.1732687324535302348.davem@davemloft.net>
References: <CAOMZO5DfQZrP-qNdPC5hJ_J+e-mX547SMq1wUC3NXWzyx84PMw@mail.gmail.com>
	<87lh5zpbaw.fsf@belgarion.home>
	<87wpp3mjt1.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: festevam@gmail.com, g.liakhovetski@gmx.de,
	mitake@dcl.info.waseda.ac.jp, fabio.estevam@freescale.com,
	mitake.hitoshi@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87wpp3mjt1.fsf@belgarion.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Tue, 15 Mar 2016 23:56:58 +0100

> Robert Jarzmik <robert.jarzmik@free.fr> writes:
> 
>> Fabio Estevam <festevam@gmail.com> writes:
>>> Tested-by: Fabio Estevam <fabio.estevam@nxp.com>
>>
>> Thanks Fabio for the test.
>>
>> I also tried with a different different approach.
>>
>> I built the different platforms (imx v6, etc ...) :
>>  - one version (a) on a vanilla v4.5-rc2
>>  - one version (b) on a vaniall v4.5-rc2 + this patch
>>
>> For each of the builds, I took the preprocessed output of smc911x.c, and made a
>> diff between (a) and (b). The commands used were :
>>  - building in [1]
>>  - diffing in [2]
>>
>> The result is [3]. I conclude from [3] that the driver cannot break for non PXA
>> platforms.
>>
>> With Fabio's test and this demonstration, is enough to convince you to apply
>> this patch David ?
> Hi David,
> 
> Can you consider this patch now it is tested please ?

Please resubmit the patch fresh with the appropriate Tested-by: tags
added, thanks.
