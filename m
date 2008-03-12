From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Re: WAN: new PPP code for generic HDLC
Date: Wed, 12 Mar 2008 20:25:10 +0100
Message-ID: <m37ig7sq21.fsf@maximus.localdomain>
References: <m3prtzsszg.fsf@maximus.localdomain>
	<m3lk4nsskh.fsf@maximus.localdomain> <20080312115215.5fb1a370@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:36848 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751752AbYCLTZN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2008 15:25:13 -0400
In-Reply-To: <20080312115215.5fb1a370@extreme> (Stephen Hemminger's message of "Wed\, 12 Mar 2008 11\:52\:15 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

>> +struct hdlc_header {
>> +	u8 address;
>> +	u8 control;
>> +	__be16 protocol;
>> +} __attribute__ ((packed));
>> +
>> +struct cp_header {
>> +	u8 code;
>> +	u8 id;
>> +	__be16 len;
>> +} __attribute__ ((packed));
>> +
>
> If I remember correctly, the packed is unnecessary for structures like this
> and causes GCC to generate worse code.

Interesting. Gcc obviously will do the right thing without "packed",
at least on "current" architectures, but I don't know what the C
standard says. I will remove it, thanks.
-- 
Krzysztof Halasa
