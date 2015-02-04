From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH] net: sched: One function call less in em_meta_change()
 after error detection
Date: Wed, 04 Feb 2015 10:54:14 +0100
Message-ID: <54D1EC46.1020201@users.sourceforge.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>	<5317A59D.4@users.sourceforge.net>	<54CD042E.6030606@users.sourceforge.net> <20150203.161054.379086029122558267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: David Miller <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150203.161054.379086029122558267.davem@davemloft.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> The meta_delete() function could be called in four cases by the
>> em_meta_change() function during error handling even if the passed
>> variable "meta" contained still a null pointer.
>>
>> * This implementation detail could be improved by adjustments for jump labels.
>>
>> * Let us return immediately after the first failed function call according to
>>   the current Linux coding style convention.
>>
>> * Let us delete also unnecessary checks for the variables "err" and
>>   "meta" there.
> 
> I kind of like the way the code is now, branching to the end of the function
> even when cleanups are not necessary.

I would appreciate if the affected exception handling can become also
a bit more efficient.

Regards,
Markus

