From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net v2] net: sctp: wake up all assocs if sndbuf policy
 is per socket
Date: Tue, 08 Apr 2014 14:19:18 -0400 (EDT)
Message-ID: <20140408.141918.1353780924646899277.davem@redhat.com>
References: <53442A62.3050905@redhat.com>
	<20140408.131819.1373401078750444800.davem@davemloft.net>
	<53442FD0.5020609@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org, tgraf@suug.ch,
	nhorman@tuxdriver.com, vyasevic@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10361 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757532AbaDHSTw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 14:19:52 -0400
In-Reply-To: <53442FD0.5020609@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 08 Apr 2014 19:20:16 +0200

> On 04/08/2014 07:18 PM, David Miller wrote:
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Tue, 08 Apr 2014 18:57:06 +0200
>>
>>> Hm, I still found an issue, please hold on with this one, thanks.
>>
>> Ugh too late I pushed it out, you'll need to send a relative fix.
> 
> No problem, will do, thanks. I suggest to take it out from
> the stable queue for now. Sorry for any inconvenience.

I'm going to keep it in there and add the fixup when you submit it,
I'll make a mental note not to apply it until the fixup is in too.

I always re-read all of the discussion in the patchwork entry for
a patch when I backport it to -stable, so it's very unlikely that
I will accidently apply it without the fixup.

Thanks.
