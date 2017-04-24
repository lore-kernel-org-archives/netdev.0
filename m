From: Karim Eshapa <karim.eshapa@gmail.com>
Subject: RE:PATCH drivers:net:cris/eth_v10: alternate string char arrary
Date: Mon, 24 Apr 2017 21:54:42 +0200
Message-ID: <1493063682-8560-1-git-send-email-karim.eshapa@gmail.com>
References: <1493056179-6460-1-git-send-email-karim.eshapa@gmail.com>
Cc: felipe.balbi@linux.intel.com, paul.gortmaker@windriver.com,
        mugunthanvnm@ti.com, jarod@redhat.com, fw@strlen.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Karim Eshapa <karim.eshapa@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34516 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S977210AbdDXTyx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 15:54:53 -0400
In-Reply-To: <1493056179-6460-1-git-send-email-karim.eshapa@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On  Mon, 24 Apr 2017 14:18:58 -0400 (EDT), David Miller wrote:
> Mon, 24 Apr 2017 19:49:39 +0200, Karim Eshapa wrote:
>>
>> static char pointer creates two variables in final assembly.
>> static string and pointer to it according to
>> Jeff Garzik janitors TODO.
>
> Instead of trusting some document written more than 10 years ago on
> the internet, why don't you build the source file in question and take
> a look at what actually happens?
>

I've just dumped the assembly and symbols. I didn't find 
extraordinary difference between the two strings.
sorry for that, but why is that still there in 
TODO kerneljanitors at kernelnewbies.

Thanks,
Karim
