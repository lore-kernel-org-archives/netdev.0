From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] net: usb: initialize tmp in dm9601.c to avoid warning
Date: Fri, 18 Jan 2013 08:37:41 +0100
Message-ID: <87sj5zj60q.fsf@dell.be.48ers.dk>
References: <1358450989-25205-1-git-send-email-sque@chromium.org>
	<87wqvbjujl.fsf@dell.be.48ers.dk>
	<20130117.175454.200184894667897570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sque@chromium.org, netdev@vger.kernel.org, msb@chromium.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:36086 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab3ARHhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 02:37:54 -0500
Received: by mail-ee0-f43.google.com with SMTP id c50so1637882eek.16
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 23:37:46 -0800 (PST)
In-Reply-To: <20130117.175454.200184894667897570.davem@davemloft.net> (David
	Miller's message of "Thu, 17 Jan 2013 17:54:54 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "David" == David Miller <davem@davemloft.net> writes:

 >> What warning and what compiler version are you using?

 David> I wouldn't bother asking this, unless it's so that you personally
 David> can reproduce this in the future.

 David> The compiler cannot determine with %100 certainty that tmp is
 David> initialized in all paths.  Any time there are conditional
 David> statements guarding setting and the use, the compiler is going
 David> to err on the side of caution and say that if any of those
 David> paths lead to a use without a set it's going to warn.

Sure, I just wondered as the code hasn't changed in 5+ years, and the
function that gets called is defined just above, so the compiler should
be able to figure it out.

-- 
Bye, Peter Korsgaard
