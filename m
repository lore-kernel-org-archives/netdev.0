From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: Simplify MSI interrupt testing
Date: Mon, 13 Sep 2010 22:20:55 -0700
Message-ID: <AANLkTinh6pAT9PsHZa1vaD6uQQZY_qWV68Bmx--f0Y4m@mail.gmail.com>
References: <201009131045.40018.jdelvare@suse.de>
	<20100913.201340.68129542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: jdelvare@suse.de, bruce.w.allan@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60848 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129Ab0INFU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 01:20:57 -0400
Received: by iwn5 with SMTP id 5so5782182iwn.19
        for <netdev@vger.kernel.org>; Mon, 13 Sep 2010 22:20:56 -0700 (PDT)
In-Reply-To: <20100913.201340.68129542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 13, 2010 at 20:13, David Miller <davem@davemloft.net> wrote:
> From: Jean Delvare <jdelvare@suse.de>
> Date: Mon, 13 Sep 2010 10:45:39 +0200
>
>> The code is quite convoluted, simplify it. This also avoids calling
>> e1000_request_irq() without testing the value it returned, which was
>> bad.
>>
>> Signed-off-by: Jean Delvare <jdelvare@suse.de>
>> Cc: Bruce Allan <bruce.w.allan@intel.com>
>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>> I understand that we need to request the IRQ again after testing, but
>> why doing it twice?
>>
>> I sent this patch to the e1000-devel list on August 26th, 2010, but
>> didn't receive any answer:
>> http://sourceforge.net/mailarchive/forum.php?thread_name=201008261445.44334.jdelvare%40suse.de&forum_name=e1000-devel
>
> Intel folks, please provide feedback or else I'll just blindly apply Jean's
> patch to the net-next-2.6 tree as long as it compiles ;-)
> --

Sorry, I believe this patch is good to go.  I am still trying to catch
up on email after being out on vacation.

Let me verify that we tested this patch and get back to you (later
tonight) Dave.

-- 
Cheers,
Jeff
