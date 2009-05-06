From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Wed, 06 May 2009 16:08:15 -0500
Message-ID: <4A01FC3F.7080004@freescale.com>
References: <1241640919-4650-1-git-send-email-wd@denx.de>	<1241640919-4650-3-git-send-email-wd@denx.de> <fa686aa40905061333q29c263c8p24856c048e30f4d0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Denk <wd@denx.de>, linuxppc-dev@ozlabs.org,
	Piotr Ziecik <kosmo@semihalf.com>,
	John Rigby <jrigby@gmail.com>, netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:40144 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbZEFVI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 17:08:27 -0400
In-Reply-To: <fa686aa40905061333q29c263c8p24856c048e30f4d0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Likely wrote:
>>  #ifdef CONFIG_FS_ENET_HAS_FEC
>> +#ifdef CONFIG_FS_ENET_MPC5121_FEC
>> +       {
>> +               .compatible = "fsl,mpc5121-fec",
>> +               .data = (void *)&fs_fec_ops,
>> +       },
>> +#else
>>        {
>>                .compatible = "fsl,pq1-fec-enet",
>>                .data = (void *)&fs_fec_ops,
>>        },
>>  #endif
>> +#endif
> 
> Hmmm.  A lot of these #ifdefs in here.  Does this have a multiplatform
> impact?  Not to mention the fact that it's just plain ugly.  :-)

Multiplatform between 512x and 8xx is currently impossible for other 
reasons (512x and CPM2 is another matter).  That said, less ifdefs would 
be nice.

-Scott
