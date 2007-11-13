From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH][NET] Convert init_timer into setup_timer
Date: Tue, 13 Nov 2007 17:02:08 +0300
Message-ID: <4739AE60.4030906@openvz.org>
References: <4739A22B.20600@openvz.org> <20071113.053421.68786227.davem@davemloft.net> <20071113134340.GI3943@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51373 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751650AbXKMOCW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 09:02:22 -0500
In-Reply-To: <20071113134340.GI3943@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> Em Tue, Nov 13, 2007 at 05:34:21AM -0800, David Miller escreveu:
>> From: Pavel Emelyanov <xemul@openvz.org>
>> Date: Tue, 13 Nov 2007 16:10:03 +0300
>>
>>> Many-many code in the kernel initialized the timer->function 
>>> and  timer->data together with calling init_timer(timer). There 
>>> is already a helper for this. Use it for networking code.
>>>
>>> The patch is HUGE, but makes the code 130 lines shorter 
>>> (98 insertions(+), 228 deletions(-)).
>>>
>>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>> I have no objection to this patch, but it is 2.6.25
>> material for sure.

OK.

> Agreed, Pavel, if you want please stick:
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Thanks! :)

> - Arnaldo
> 

