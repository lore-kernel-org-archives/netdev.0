From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH] net-libertas: Better exception handling in
 if_spi_host_to_card_worker()
Date: Sat, 2 Jan 2016 09:09:23 +0100
Message-ID: <568785B3.5000905@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5686F0B2.5000000@users.sourceforge.net>
 <56870866.7020000@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <56870866.7020000@cogentembedded.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Move the jump label directly before the desired log statement
>> so that the variable "err" will not be checked once more
>> after it was determined that a function call failed.
>> Use the identifier "report_failure" instead of the label "err".
> 
>    Why?

I suggest to reconsider the places with which such a jump label
is connected.


> The code was smart enough

Which action should really be performed after a failure was detected
and handled a bit already?

* Another condition check

* Just additional error logging


> and you're making it uglier that it needs to be.

I assume that a software development taste can evolve, can't it?

Regards,
Markus
