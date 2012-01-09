From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] r6040: fix typo in use of MCR0 register bits
Date: Mon, 09 Jan 2012 11:15:27 +0100
Message-ID: <4F0ABE3F.2040307@openwrt.org>
References: <1325949197-10143-1-git-send-email-cesarb@cesarb.net> <20120107.120947.1387951434734479835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cesarb@cesarb.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120107.120947.1387951434734479835.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/07/12 21:09, David Miller wrote:
> From: Cesar Eduardo Barros<cesarb@cesarb.net>
> Date: Sat,  7 Jan 2012 13:13:17 -0200
>
>> Commit 4e16d6ebd65b4f2c4e3f780b4c5704beef64019c (r6040: define more MCR0
>> register bits) added #define values for MCR0 register bits and converted
>> uses of hardcoded magic values to uses of these defines.
>>
>> However, one of the conversions looks suspicious:
>>
>>   #define MCR0		0x00	/* Control register 0 */
>> +#define  MCR0_RCVEN	0x0002	/* Receive enable */
>> +#define  MCR0_XMTEN	0x1000	/* Transmission enable */
>>
>>   	/* Init RDC private data */
>> -	lp->mcr0 = 0x1002;
>> +	lp->mcr0 = MCR0_XMTEN | MCR0;
>>
>> I believe what was meant here was MCR0_XMTEN | MCR0_RCVEN, which makes
>> sense and matches the original values.
>>
>> Signed-off-by: Cesar Eduardo Barros<cesarb@cesarb.net>
> Good catch, applied, thanks a lot.
Indeed, thanks Cesar.
--
Florian
