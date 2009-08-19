From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] revert TCP retransmission backoff on ICMP destination
 unreachable
Date: Tue, 18 Aug 2009 23:29:33 -0700 (PDT)
Message-ID: <20090818.232933.123806647.davem@davemloft.net>
References: <4A8553AD.2000601@tvk.rwth-aachen.de>
	<alpine.DEB.2.00.0908181514560.10654@wel-95.cs.helsinki.fi>
	<4A8AE771.1070308@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50053
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751000AbZHSG3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 02:29:22 -0400
In-Reply-To: <4A8AE771.1070308@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Date: Tue, 18 Aug 2009 19:40:01 +0200

>> On Fri, 14 Aug 2009, Damian Lukowski wrote:
>> 
>>>> Longer than 80 columns, and use an inline function instead
>>>> of a macro in order to get proper type checking.
>>>> [...]
>>>> Do not break up the function local variables with spurious new lines
>>>> like this, please.
>>>> [...]
>>>> The indentation and tabbing is messed up in all of the code you are
>>>> adding, please fix it up to be consistent with the surrounding code
>>>> and the rest of the TCP stack.
>>>>
>>>> Do not use C++ style // comments.
>>>
>>> Better?
>> 
>> Please, include the changelog message on resubmits too next time.
> 
> I'm sorry, which message do you mean? I used plain diff without GIT or
> anything.

He means the commit message.

When you fix up patches, don't just reply and say "here's the fixed
up patch".  That doesn't work.

We need the full context, the full commit message, and your signoffs,
when you submit any patch you intend us to consider applying.
