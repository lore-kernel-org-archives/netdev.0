From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 1/4] [SCTP]: "list_for_each()" -> "list_for_each_entry()"
 where appropriate.
Date: Fri, 28 Mar 2008 20:59:27 -0400
Message-ID: <47ED946F.9070209@hp.com>
References: <1206716180-16573-1-git-send-email-vladislav.yasevich@hp.com>	<1206716180-16573-2-git-send-email-vladislav.yasevich@hp.com> <20080328.163218.258439481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	rpjday@crashcourse.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:40752 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754656AbYC2A7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 20:59:30 -0400
In-Reply-To: <20080328.163218.258439481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Fri, 28 Mar 2008 10:56:17 -0400
> 
>> From: Robert P. J. Day <rpjday@crashcourse.ca>
>>
>> Replacing (almost) all invocations of list_for_each() with
>> list_for_each_entry() tightens up the code and allows for the deletion
>> of numerous list iterator variables that are no longer necessary.
>>
>> Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>
>> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> 
> This is not a "bug fix", it's a huge cleanup and thus not appropriate
> for 2.6.x
> 
> Please rebuild this patch series without this patch included,
> you can submit it for 2.6.26
> 

Sorry about that, you are right.  Will do.

-vlad
