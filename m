From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ip route: Add annotation for replaced routes
Date: Tue, 14 Jun 2016 15:37:01 -0600
Message-ID: <34430dc7-9393-125a-bed9-46cd1a79b919@cumulusnetworks.com>
References: <1465502742-17289-1-git-send-email-dsa@cumulusnetworks.com>
 <20160614143423.5f202e8c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32794 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbcFNVhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 17:37:04 -0400
Received: by mail-pa0-f41.google.com with SMTP id b13so890684pat.0
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 14:37:04 -0700 (PDT)
In-Reply-To: <20160614143423.5f202e8c@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/14/16 3:34 PM, Stephen Hemminger wrote:
> On Thu,  9 Jun 2016 13:05:42 -0700
> David Ahern <dsa@cumulusnetworks.com> wrote:
>
>> If NLM_F_REPLACE flag is set then a route is replacing an existing route.
>> Prepend "Replaced " to these routes similar to how "Deleted " is added
>> to deleted routes.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>
> Why just routes, there are several other places where Replaced entries could
> be returned?
>

b/c that's the use case I was investigating. :-)

Will add the others.
