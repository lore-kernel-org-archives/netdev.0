From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Thu, 7 May 2009 08:05:02 -0500
Message-ID: <983C93C9-4AA8-421B-B7F8-770E2FD672E1@kernel.crashing.org>
References: <1241640919-4650-1-git-send-email-wd@denx.de>
	<1241640919-4650-3-git-send-email-wd@denx.de>
	<fa686aa40905061333q29c263c8p24856c048e30f4d0@mail.gmail.com>
	<20090506220119.7322783420E8@gemini.denx.de>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: Piotr Ziecik <kosmo@semihalf.com>, John Rigby <jrigby@freescale.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Detlev Zundel <dzu@denx.de>
To: Wolfgang Denk <wd@denx.de>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090506220119.7322783420E8@gemini.denx.de>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On May 6, 2009, at 5:01 PM, Wolfgang Denk wrote:

> Dear Grant,
>
> in message <fa686aa40905061333q29c263c8p24856c048e30f4d0@mail.gmail.com 
> > you wrote:
>>
> ...
>>> #ifdef CONFIG_FS_ENET_HAS_FEC
>>> +#ifdef CONFIG_FS_ENET_MPC5121_FEC
>>> +    {
>>> +        .compatible = "fsl,mpc5121-fec",
>>> +        .data = (void *)&fs_fec_ops,
>>> +    },
>>> +#else
>>>   {
>>>       .compatible = "fsl,pq1-fec-enet",
>>>       .data = (void *)&fs_fec_ops,
>>>   },
>>> #endif
>>> +#endif
>>
>> Hmmm.  A lot of these #ifdefs in here.  Does this have a  
>> multiplatform
>> impact?  Not to mention the fact that it's just plain ugly.  :-)
>
> Agreed that it's ugly, but duplicatio9ng the code would have been even
> worse. I don't think that it has multiplatform - at least not as long
> as you don't ask for one image that runs on 83xx and on 512x.

We do ask for that.  The fedora ppc6xx kernel should work on any 6xx/ 
7xx/7xxx based core chip.  We should NOT be breaking such capability  
in drivers.

- k
