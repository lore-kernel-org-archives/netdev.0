From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: E1000E/82567LM-3: link reported up too soon
Date: Tue, 21 Sep 2010 13:03:10 +0200
Message-ID: <87iq1z8ikx.fsf@small.ssi.corp>
References: <87y6awjhxv.fsf@small.ssi.corp>
	<20100920.131839.173838219.davem@davemloft.net>
	<87aancqf3a.fsf@small.ssi.corp>
	<20100920.152352.193726412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:51226 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753085Ab0IULC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Sep 2010 07:02:29 -0400
In-Reply-To: <20100920.152352.193726412.davem@davemloft.net> (David Miller's
	message of "Mon, 20 Sep 2010 15:23:52 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Miller <davem@davemloft.net> writes:

> From: arno@natisbad.org (Arnaud Ebalard)
> Date: Mon, 20 Sep 2010 23:28:57 +0200
>
>> I added printk() to see where/if those first packets get dropped in
>> e1000e code. I followed those first packets to e1000_xmit_frame() and
>> don't see anything obvious happening there, i.e. they are passed to the
>> device as expected.
>
> I suspect the packet is sucessfully given to the chip and the PHY simply
> doesn't put it onto the wire for whatever reason.

I spent additional time on it, putting printk() at various locations in
e1000e driver code and also using driver's debug functions to see what
could be different in the internal state when the first packet is
delivered and when it is not. I just found nothing, so AFAICT your guess
above is backed up by those tests. 

I will try and summarize that for Intel ethernet drivers maintainers.

Cheers,

a+
