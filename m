From: hejianet <hejianet@gmail.com>
Subject: Re: [RFC PATCH v2 1/6] proc: Reduce cache miss in
 {snmp,netstat}_seq_show
Date: Wed, 7 Sep 2016 10:29:04 +0800
Message-ID: <9249517a-7f04-3bd2-3bf0-4370f63aad3c@gmail.com>
References: <1473129009-20478-1-git-send-email-hejianet@gmail.com>
 <1473129009-20478-2-git-send-email-hejianet@gmail.com>
 <20160906.155757.924163804989771884.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        vyasevich@gmail.com, nhorman@tuxdriver.com,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160906.155757.924163804989771884.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 9/7/16 6:57 AM, David Miller wrote:
> From: Jia He <hejianet@gmail.com>
> Date: Tue,  6 Sep 2016 10:30:04 +0800
>
>> +#define MAX(a, b) ((u32)(a) >= (u32)(b) ? (a) : (b))
Thanks
B.R.
Jia

> Please do not define private min/max macros, use the existing max_t()
> or similar as needed.
>
