From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: protocol 0000 is buggy, dev nlmon
Date: Mon, 04 Aug 2014 15:18:08 +0200
Message-ID: <53DF8810.9050408@redhat.com>
References: <8CB882A0-240B-4759-A119-8867FCF70957@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20674 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375AbaHDNSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2014 09:18:14 -0400
In-Reply-To: <8CB882A0-240B-4759-A119-8867FCF70957@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2014 08:05 PM, Marcel Holtmann wrote:
> Hi Daniel,
>
> when actually using nlmon, I get tons and tons of protocol xxxx is buggy warnings. Seems it misses setting the network_header correctly.
>
> And on that note, I also found that we can not get the multicast group id from nlmon. This is something we should include to be able to distinguish where netlink messages are send to.

I'll look into it, thanks Marcel.

> Regards
>
> Marcel
>
