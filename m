From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 4/9] net: Move rth handling from
 ip_route_input_slow to helper
Date: Tue, 22 Sep 2015 21:07:16 -0600
Message-ID: <56021764.1070701@cumulusnetworks.com>
References: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
 <1442962523-3974-5-git-send-email-dsa@cumulusnetworks.com>
 <56020F74.8000605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33763 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbbIWDHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 23:07:07 -0400
Received: by pacex6 with SMTP id ex6so27031400pac.0
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 20:07:06 -0700 (PDT)
In-Reply-To: <56020F74.8000605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/22/15 8:33 PM, Alexander Duyck wrote:
> Why pass loopback_dev instead of just passing the net pointer?  Seems
> like in the path below there are cases where you end up not needing to
> dereference it and it might be worth the effort to avoid dereferencing
> it if you don't need to.
>
> Same thing for nopolicy.  Why not just pass the in_dev pointer and
> handle getting the policy if you need it.

Sure, I was passing in what was needed but I get your point. If the 
cache version is valid it is an unnecessary dereference.
