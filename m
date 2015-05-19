From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Mon, 18 May 2015 22:57:16 -0700
Message-ID: <555AD0BC.7000608@cumulusnetworks.com>
References: <1431906125-13808-1-git-send-email-roopa@cumulusnetworks.com> <20150518.161916.2132217836491222672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, john.fastabend@gmail.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34501 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbbESF5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 01:57:18 -0400
Received: by pabru16 with SMTP id ru16so8981122pab.1
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 22:57:18 -0700 (PDT)
In-Reply-To: <20150518.161916.2132217836491222672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/18/15, 1:19 PM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Sun, 17 May 2015 16:42:05 -0700
>
>> On most systems where you can offload routes to hardware,
>> doing routing in software is not an option (the cpu limitations
>> make routing impossible in software).
> You absolutely do not get to determine this policy, none of us
> do.
>
> What matters is that by default the damn switch device being there
> is %100 transparent to the user.
>
> And the way to achieve that default is to do software routes as
> a fallback.
>
> I am not going to entertain changes of this nature which fail
> route loading by default just because we've exceeded a device's
> HW capacity to offload.
>
> I thought I was _really_ clear about this at netdev 0.1
sorry if i missed you emphasize this.
Current fib hw offload code aborts hw offload on the first hw offload 
failure and moves all routes to software and before 4.1 goes out I was 
trying to revisit this because the existing defaults will not work for 
most devices. To that effect, i started with an RFC patch to get some 
current thoughts and hence this patch.

I will follow up on the other options mentioned in the comment.
