From: Martin Kelly <martin@martingkelly.com>
Subject: Re: Question about synchronize_net() in AF_PACKET close()
Date: Wed, 10 Sep 2014 14:39:48 -0700
Message-ID: <CAN8CM3xk3M1gt-aofb0t11x=7mrAmKjvW3ZpVHY-2TMwBqt-NQ@mail.gmail.com>
References: <CAN8CM3zo3bMxZV_UvywCPNjJrMwMA2-+POfY8cR429iodHRc+A@mail.gmail.com>
	<20140909.150000.1647602729214485795.davem@davemloft.net>
	<54104FE6.4030404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:59249 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753580AbaIJVjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 17:39:49 -0400
Received: by mail-wg0-f47.google.com with SMTP id y10so4815806wgg.30
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 14:39:48 -0700 (PDT)
In-Reply-To: <54104FE6.4030404@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>
> And also http://patchwork.ozlabs.org/patch/181605/
> Which was an attempt on improving it.
>
> Marcelo
>

Yes, the patch I'm testing right now is very similar to the one
mentioned in that link. Whether or not the optimization is worth the
added complexity is a separate discussion. For now, I'm interested in
whether the optimization can be safely performed, both for improving
close() performance and for my own understanding of the code.
