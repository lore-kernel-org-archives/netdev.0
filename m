From: Vinson Lee <vlee@twitter.com>
Subject: Re: [STABLE REQUEST] Merge to linux-3.4.y net: Downgrade
 CAP_SYS_MODULE deprecated message from error to warning.
Date: Thu, 14 Feb 2013 16:16:18 -0800
Message-ID: <CAKixpbhtD-mhAESjV3HOZRxYqvsWrjH0vTpDgKZuUismUvVa-g@mail.gmail.com>
References: <CAKixpbjutA_84JzM0Zjtw-Pxo8m3KCP9+R_aSJWTPaCqCsVbsw@mail.gmail.com>
	<20130214233735.GA4390@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stable@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	mirq-linux@rere.qmqm.pl, jpirko@redhat.com, therbert@google.com,
	netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:61843 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935228Ab3BOAQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 19:16:20 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so1566697eei.21
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 16:16:19 -0800 (PST)
In-Reply-To: <20130214233735.GA4390@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 14, 2013 at 3:37 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> On Thu, Feb 14, 2013 at 03:29:44PM -0800, Vinson Lee wrote:
>> Hi.
>>
>> I would like to nominate commit
>> 7cecb523adedcaf8acba5e14d47559d8bc3f40d7 for backport to stable
>> branches 3.4 and earlier.
>>
>> commit 7cecb523adedcaf8acba5e14d47559d8bc3f40d7
>> Author: Vinson Lee <vlee@twitter.com>
>> Date:   Wed Jun 27 14:32:07 2012 +0000
>>
>>     net: Downgrade CAP_SYS_MODULE deprecated message from error to warning.
>>
>>     Make logging level consistent with other deprecation messages in net
>>     subsystem.
>>
>>     Signed-off-by: Vinson Lee <vlee@twitter.com>
>>     Cc: David Mackey <tdmackey@twitter.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> I fail to see how this patch meets the rules described in
> Documentation/stable_kernel_rules.txt.  What am I missing?
>
> thanks,
>
> greg k-h

I am logging different kernel log-level messages to different files
and monitoring them here. I see this message most often in the errors
pile. It's arguable that this is not a bug, but it is definitely
bothering me here. Please consider for backport but I would understand
if this request was turned down.

Cheers,
Vinson
