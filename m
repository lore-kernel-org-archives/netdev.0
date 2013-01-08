From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC patch net-next] ipv4: use bcast as dst address in case
 IFF_NOARP is set
Date: Tue, 8 Jan 2013 18:45:38 +0100
Message-ID: <20130108174538.GC1621@minipsycho.orion>
References: <1357650162-5554-1-git-send-email-jiri@resnulli.us>
 <7abb4995-17a4-49ca-b0a7-41af6ff763e1@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, edumazet@google.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, pavlix@pavlix.net
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:62422 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756804Ab3AHRpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 12:45:42 -0500
Received: by mail-we0-f173.google.com with SMTP id z2so573882wey.18
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 09:45:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <7abb4995-17a4-49ca-b0a7-41af6ff763e1@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 08, 2013 at 06:11:55PM CET, stephen.hemminger@vyatta.com wrote:
>
>> When IFF_NOARP is set on a device, dev->dev_addr is used as *dst*
>> addr of sent frames. That does not make sense. Use rather bcast
>> address
>> instead.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>What did you test this on? I think this may have been
>intentional to avoid broadcasting.

Thanks for looking at this Stephen.

I tested this on two boxes connected via ethernet.

I believe this may have been intentional, but what sense does it have to
use dev_addr as destination address? That is what I do not understand.

Also, what is the issue with sending all packets to broadcast when NOARP is
set? In my opinion, it only makes sense.
