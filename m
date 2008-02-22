From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RTNL]: Validate hardware and broadcast address attribute for
 RTM_NEWLINK
Date: Fri, 22 Feb 2008 14:33:26 +0100
Message-ID: <47BECF26.6030805@trash.net>
References: <20080222125702.GB20815@postel.suug.ch> <47BEC89E.9030909@trash.net> <20080222133135.GC20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:63796 "EHLO
	viefep19-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758233AbYBVNdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 08:33:46 -0500
In-Reply-To: <20080222133135.GC20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote:
> * Patrick McHardy <kaber@trash.net> 2008-02-22 14:05
>> Minor nitpick: it would be more logical to put this in the
>>
>> if (dev) {
>>  ...
>>
>> branch a bit below since thats the only path that leads to
>> do_setlink(). That would also allow to remove the
>> if (dev) check from validate_linkmsg().
> 
> I knew this question would come up :-)

:)

> The reason I did it this way is to keep validate_linkmsg() generic
> and make it possible to put validation code which must also apply
> to new links (dev==NULL) into that function.

OK, thanks for the explanation.

