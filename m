From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] net: usb: initialize tmp in dm9601.c to avoid warning
Date: Fri, 18 Jan 2013 09:44:40 +0100
Message-ID: <87fw1ykhhj.fsf@dell.be.48ers.dk>
References: <87wqvbjujl.fsf@dell.be.48ers.dk>
	<20130117.175454.200184894667897570.davem@davemloft.net>
	<87sj5zj60q.fsf@dell.be.48ers.dk>
	<20130118.030341.2246222347501217868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sque@chromium.org, netdev@vger.kernel.org, msb@chromium.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:51551 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053Ab3ARIoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 03:44:46 -0500
Received: by mail-ea0-f169.google.com with SMTP id d13so1402172eaa.0
        for <netdev@vger.kernel.org>; Fri, 18 Jan 2013 00:44:45 -0800 (PST)
In-Reply-To: <20130118.030341.2246222347501217868.davem@davemloft.net> (David
	Miller's message of "Fri, 18 Jan 2013 03:03:41 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "David" == David Miller <davem@davemloft.net> writes:

 >> Sure, I just wondered as the code hasn't changed in 5+ years, and the
 >> function that gets called is defined just above, so the compiler should
 >> be able to figure it out.

 David> Nothing guarentees that a piece of memory passed into an external
 David> function has it's contents initialized completely by that function.

 David> The compiler can't see what usbnet_read_cmd() does with the memory
 David> behind the 'data' pointer argument.  So it makes the only assumption
 David> it can make, which is that 'tmp' might be uninitialized.

True, I had forgotten about the usbnet_read_cmd() change (which is the
change causing the warning). With that:

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

-- 
Bye, Peter Korsgaard
