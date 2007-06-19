From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: Re: [RFC][PATCH -mm take5 4/7] using symlink for the net_device
Date: Tue, 19 Jun 2007 19:03:50 +0900
Message-ID: <4677AA06.4090600@bx.jp.nec.com>
References: <466FC455.5060001@bx.jp.nec.com> <466FC6ED.9060208@bx.jp.nec.com> <a781481a0706130949j7b35e33ds9cda5d8a551c9d7d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Satyam Sharma <satyam.sharma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:56548 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757353AbXFSKEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 06:04:10 -0400
In-Reply-To: <a781481a0706130949j7b35e33ds9cda5d8a551c9d7d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Satyam,

> Sorry, but we're not covering from the error condition fully here. Note
> that later you merge the temporary modify_target_list entirely back
> into the target_list ... which would still contain these erroneous
> nodes. A full cleanup (kobject_unregister the entry, and then list_del
> from modify_target_list) is required here, before continuing.

I will fix this. If the error occurs, I think so that we need to cleanup
completely.

>> +                       strcpy(nt->np.dev_name, dev->name);
> 
> ... you'll have move this up.
> 

Why? I don't have opposition about moving this up, but I'm misplacing the abobe code?
or it isn't appropriate about coding style?

Thanks
-- 
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com



