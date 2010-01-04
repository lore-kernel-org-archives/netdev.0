From: Daniele Venzano <venza@brownhat.org>
Subject: Re: [PATCH] sis900: print warning if MAC address is not available
Date: Mon, 04 Jan 2010 20:08:07 +0100
Message-ID: <1262632087-1a12402612d0c4fe5bd0e2bd0dedbdb2@brownhat.org>
References: <20100103.215727.177625500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	erik.andren@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.infomaniak.ch ([84.16.68.90]:47841 "EHLO
	smtp2.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab0ADTIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 14:08:20 -0500
In-Reply-To: <20100103.215727.177625500.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Your mail DID ring a bell...

The correct patch already got in at the beginning of last year in
commit d1d5e6b1cead3df6f722d1d458874bd7f93da8d6.

Closing related bugs, sorry for the noise.

----- Message d'origine -----
De: David Miller <davem@davemloft.net>
Date: Sun, 03 Jan 2010 21:57:27 -0800 (PST)
Sujet: Re: [PATCH] sis900: print warning if MAC address is not available

>From: Daniele Venzano <venza@brownhat.org>
>Date: Wed, 30 Dec 2009 19:22:43 +0100
>
>> The attached patch prints a warning if the MAC address is all 0s in the
>> sis900 driver.
>> 
>> The patch prints a warning whenever the MAC address read from the
>> hardware is composed of all zeros.
>> If the address cannot be read at all for some reason, the driver is
>> already doing the right thing and bails out.
>> In reference to bug 11649 from bugzilla.


--
Daniele Venzano
venza@brownhat.org
http://www.brownhat.org
