From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 05/05] ipv6: RFC4214 Support (3)
Date: Wed, 14 Nov 2007 15:09:17 -0500
Message-ID: <473B55ED.9030104@hp.com>
References: <473371B3.5030908@yahoo.com>	<4734FCEF.3080301@yahoo.com>	<20071113125312.4c4d1391@freepuppy.rosehill> <20071113.210513.157206334.davem@davemloft.net> <473A838A.5060603@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, osprey67@yahoo.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:38023 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754926AbXKNUTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 15:19:10 -0500
In-Reply-To: <473A838A.5060603@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> David Miller wrote:
>> From: Stephen Hemminger <shemminger@linux-foundation.org>
>> Date: Tue, 13 Nov 2007 12:53:12 -0800
>>
>>  
>>> On Fri, 09 Nov 2007 16:35:59 -0800
>>> osprey67 <osprey67@yahoo.com> wrote:
>>>
>>>    
>>>> From: Fred L. Templin <fred.l.templin@boeing.com>
>>>>
>>>> This message attaches the combined diffs from
>>>> messages 01/05 through 04/05. This file should be
>>>> suitable for use with the patch utility.
>>>>
>>>> Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
>>>>
>>>>       
>>> Isn't increasing the size of struct ip_tunnel_parm
>>> going to cause kernel ABI changes?
>>>     
>>
>> Yeah it is, unfortunately.
>>   
> So we can't take it.  It might be possible to extend the structure if
> you put the
> new parameters at the end and handled the compatibility cases correctly.

It's fixed in the later patch set.

-vlad
