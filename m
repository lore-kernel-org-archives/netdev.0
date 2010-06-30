From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: TCP not triggering a fast retransmit?
Date: Wed, 30 Jun 2010 13:43:41 -0700
Message-ID: <65D4D5A1-78E9-4479-97AF-D2BE598564FD@earthlink.net>
References: <AANLkTinJC6uS1GTbKJWL9AlEs2e5GleQvJbTUZrsQHaE@mail.gmail.com> <9E73042B-BF54-48FD-8755-C215FD03C9AE@earthlink.net> <AANLkTimpofANvn-sDZrE3kdq9owzYe8DJa8OfuVK04cM@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmatthews@greenplum.com,
	Tim Heath <theath@greenplum.com>
To: Ivan Novick <novickivan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:43966 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753592Ab0F3Uns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 16:43:48 -0400
In-Reply-To: <AANLkTimpofANvn-sDZrE3kdq9owzYe8DJa8OfuVK04cM@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 30, 2010, at 1:14 PM, Ivan Novick wrote:

> On Wed, Jun 30, 2010 at 1:06 PM, Mitchell Erblich
> <erblichs@earthlink.net> wrote:
>> On Jun 30, 2010, at 11:04 AM, Ivan Novick wrote:
> ... snip ...
>> Sometimes, adding tracing within the tcps, can identify if.
>> the tcp flow has periods of idleness,
>> the tcp flow is/has been application limited versus network limited,
>> whether the flow is in SS or CA?
>> CA normally has DELayed ACks, which reduces the number
>>    of ACKs to 1/2 or more,
>> Whether Fast re-xmit is triggered by 2 or 3 DupAcks.
>> whether any burst avoidance has occured,
>> etc,
> 
> Hi Mitchell,
> 
> When you say adding tracing within the tcps... what method are you
> referring to, to add this tracing?  Is it some tool or setting or are
> you talking about adding custom debugging output to the kernel?
> 
> Cheers,
> Ivan

Ivan,

Custom debug code that was added into the fast-path
   when extensive tcp flow analysis is desired.
Uses a runtime /proc var to not effect the fast-path
   that by default is dis-abled.

Mitchell Erblich


