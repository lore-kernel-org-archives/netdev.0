From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][XFRM] export SPD info
Date: Fri, 27 Apr 2007 10:29:28 -0400
Message-ID: <1177684168.4059.38.camel@localhost>
References: <1177681421.4059.2.camel@localhost> <463200CC.6010207@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:58576 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755907AbXD0O3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 10:29:32 -0400
Received: by wx-out-0506.google.com with SMTP id h31so919226wxd
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 07:29:32 -0700 (PDT)
In-Reply-To: <463200CC.6010207@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-27-04 at 15:55 +0200, Patrick McHardy wrote:

> 
> It it really worth the extra code for dumping them conditionally?
> The attributes are neither large nor will they be sent very often.
> 

That thought did cross my mind when i was coding this;-> I hate the way
netlink filters are done in user space with iproute2 - dumping 50
objects just so i can get to one. So i used that as my guiding
principle; i have no qualms with the few extra lines.
Actually, I was hoping it would provide motivation for someone else to
do a better filtering scheme (which sits in the kernel).

cheers,
jamal

