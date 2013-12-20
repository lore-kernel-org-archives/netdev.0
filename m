From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: Re: [PATCH net] tg3: Expand 4g_overflow_test workaround to skb fragments
 of any size.
Date: Thu, 19 Dec 2013 17:33:31 -0800
Message-ID: <52B39E6B.1090305@broadcom.com>
References: <1387499052-7838-1-git-send-email-nsujir@broadcom.com> <1387499933.19078.379.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<stable@vger.kernel.org>, Michael Chan <mchan@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1387499933.19078.379.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> -	return (base > 0xffffdcc0) && (base + len + 8 < base);
>> +	return (base + len + 8 < base);
>>   }
>
> And it is actually faster ;)
>
> What is 8 value exactly ?
>
>

Some older devices needed to be at least 8 bytes away from the boundary. For 
simplicity we use the same check for all devices.
