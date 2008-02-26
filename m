From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver updates
Date: Mon, 25 Feb 2008 19:17:38 -0500
Message-ID: <47C35AA2.7010103@garzik.org>
References: <OF5F5F5698.07AB615F-ON652573F6.00142D8A-652573F6.00147DC9@in.ibm.com><20080220.214651.235108740.davem@davemloft.net><8A71B368A89016469F72CD08050AD334026D6511@maui.asicdesigners.com> <20080220.221554.128587906.davem@davemloft.net> <8A71B368A89016469F72CD08050AD334026D652F@maui.asicdesigners.com> <47C34838.3040502@garzik.org> <47C35999.7090307@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53755 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757405AbYBZARq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 19:17:46 -0500
In-Reply-To: <47C35999.7090307@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray wrote:
> 
>>
>> So, it sounds like Krishna's patch is ok, because the race does not 
>> exist anymore in this driver?
> The first part is right indeed, but the second part is breaking the 
> current usage of txq_stopped and
> the logic that stops and restarts the Tx queue.
> I can submit a patch fixing it. Plese let me know what's more convenient 
> for you.

At this point, yes a fix (with a good patch description) would be 
preferred...

Thanks,

	Jeff



