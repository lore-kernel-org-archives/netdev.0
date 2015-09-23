From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/9 v2] net: Refactor ip_route_input_slow
Date: Wed, 23 Sep 2015 10:08:16 -0600
Message-ID: <5602CE70.5010001@cumulusnetworks.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
 <1443022239.29850.113.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33943 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755289AbbIWQIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 12:08:19 -0400
Received: by padhy16 with SMTP id hy16so44420551pad.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 09:08:19 -0700 (PDT)
In-Reply-To: <1443022239.29850.113.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/23/15 9:30 AM, Eric Dumazet wrote:
>
> You also remove a lot of goto, but do not place likely() or unlikely()
> clauses that would help compiler to emit the same optimal code.

I do not see where I have changed the likely/unlikely aspect of the 
logic. Can you point to an example in the patches?
