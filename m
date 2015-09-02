From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: Add table id from route lookup to route
 response
Date: Wed, 2 Sep 2015 14:34:13 -0600
Message-ID: <55E75D45.2090105@cumulusnetworks.com>
References: <20150902190836.GD20527@pox.localdomain>
 <1441224980-6201-1-git-send-email-dsa@cumulusnetworks.com>
 <20150902202314.GC25648@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35038 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932130AbbIBUeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 16:34:16 -0400
Received: by igbkq10 with SMTP id kq10so34171059igb.0
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 13:34:15 -0700 (PDT)
In-Reply-To: <20150902202314.GC25648@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/2/15 2:23 PM, Thomas Graf wrote:
> On 09/02/15 at 01:16pm, David Ahern wrote:
>> IPv4 ABI has the table hardcoded as RT_TABLE_MAIN regardless of the table
>> hit for the route lookup. Add the table using a new attribute,
>> RTA_TABLE_LOOKUP, to maintain the ABI yet return the right table id.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> ---
>>
>> Thomas: Something like this?
>>
>> The current ABI is returning wrong data in some cases; that seems worse
>> to me than breaking the ABI.
>
> Another option is to introduce a new flag bundled with RTM_GETROUTE
> which fixes RTM_GETROUTE altogether and makes it return the actual
> route instead of a simulated cache entry.
>

I like that better; it least then information is not duplicated. Thanks 
for the suggestion.
