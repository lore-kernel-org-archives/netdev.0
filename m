From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: Do not keep linklocal and loopback addresses
Date: Wed, 13 Apr 2016 21:13:16 -0600
Message-ID: <570F0ACC.3080408@cumulusnetworks.com>
References: <1460142081-16675-1-git-send-email-dsa@cumulusnetworks.com>
 <20160413.230002.1718430497071707670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35384 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560AbcDNDNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 23:13:21 -0400
Received: by mail-ig0-f169.google.com with SMTP id gy3so137847537igb.0
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 20:13:20 -0700 (PDT)
In-Reply-To: <20160413.230002.1718430497071707670.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/13/16 9:00 PM, David Miller wrote:
>
> Applied, but two things:
>
> Please do not put an empty line between the Fixes: and other tags.
> All tags are equal and should be placed together as an unsegmented
> unit.

ack.

> Second, please be really sure this is the final set of semantics
> you want.  If we flap again on this after 4.6-final goes out the
> door, I will be very unpleased to say the least.

(thunderbird underlined unpleased in that sentence as if you reached 
through the screen and and put a red marker on it)

With this patch we only retain user configured addresses which is the 
goal of the v1 patch posted back in January 2015. This is active in our 
code base so getting a lot of testing and exposure to other users. It is 
active on my server and VMs as well. With all of the VRF testing it is 
getting a workout. i.e, not much more I can do to ensure this is solid 
before 4.6 is final. I know this patch has been been ported and is in 
use by others; I would encourage them to share if they see problems or 
want adjustments as well.
