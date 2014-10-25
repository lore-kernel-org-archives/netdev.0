From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net/sched: Fix use of wild pointer in mq_destroy()
 when qdisc_alloc fail
Date: Fri, 24 Oct 2014 17:57:59 -0700
Message-ID: <CAHA+R7MW-kP0uO2+00+pbx1y=LQynLWy9diznccY69+8nZ5mwQ@mail.gmail.com>
References: <OF7A403C69.2C35464E-ON48257D7B.002E24AA-48257D7B.002F2A62@zte.com.cn>
	<544A913A.1060100@gmail.com>
	<CAHA+R7P+nGXc93e_-u5Bvmr5Ri8CCg9FAgc+R7fJT7mJ5sBFwQ@mail.gmail.com>
	<20141024191418.GA8842@acer.localdomain>
	<CAHA+R7PDxYeVuQZz=VSci8_7sZ9smb5c59ivOS=B6GemJwtcCg@mail.gmail.com>
	<20141024214511.GA10290@acer.localdomain>
	<CAHA+R7PxvW6umBJMxGk0h=ht4RhoDRcrxr5WSTEUBa80TxU5GQ@mail.gmail.com>
	<20141025003348.GA11289@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.fastabend@gmail.com>,
	Wang Bo <wang.bo116@zte.com.cn>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, cui.yunfeng@zte.com.cn
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:43893 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754757AbaJYA6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 20:58:00 -0400
Received: by mail-qg0-f52.google.com with SMTP id q108so1780411qgd.39
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 17:57:59 -0700 (PDT)
In-Reply-To: <20141025003348.GA11289@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 5:33 PM, Patrick McHardy <kaber@trash.net> wrote:
>
> Its about having a sane API.

I don't see why calling ->destroy() on failure is not sane in qdisc case.
I never want to argue general case.
