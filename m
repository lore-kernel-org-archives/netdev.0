From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 00/13] net: Various VRF patches
Date: Wed, 4 May 2016 22:13:56 -0600
Message-ID: <572AC884.9090700@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
 <20160504.235932.203671415532849729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37616 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696AbcEEEOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 00:14:00 -0400
Received: by mail-ig0-f182.google.com with SMTP id s8so4785977ign.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 21:14:00 -0700 (PDT)
In-Reply-To: <20160504.235932.203671415532849729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/16 9:59 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Wed,  4 May 2016 20:33:17 -0700
>
>> Various fixes and features for VRF over the past few months.
>
> I really dislike a patch series that is simply a hodge podge of
> unrelated things.
>
> Please group your changes into logical bunches, and submit them as
> groups one at a time.

I can send them out based on the grouping mentioned in the cover letter, 
but they apply in order. I believe patch 4 is the only one that is not 
order dependent.

After several days of wrestling with the order of patches 7-13 they are 
all inherently dependent on patch 5. If you look at the diff summary 
most of the code changes are to l3mdev.{c,h} and vrf.c.

I will break out the first 4 as separate patches and re-send.
