From: David Miller <davem@davemloft.net>
Subject: Re: PATCH drivers:net:cris/eth_v10: alternate string char arrary
Date: Mon, 24 Apr 2017 16:04:28 -0400 (EDT)
Message-ID: <20170424.160428.1458422856843511349.davem@davemloft.net>
References: <1493056179-6460-1-git-send-email-karim.eshapa@gmail.com>
        <1493063682-8560-1-git-send-email-karim.eshapa@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felipe.balbi@linux.intel.com, paul.gortmaker@windriver.com,
        mugunthanvnm@ti.com, jarod@redhat.com, fw@strlen.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: karim.eshapa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57042 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S977264AbdDXUEa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 16:04:30 -0400
In-Reply-To: <1493063682-8560-1-git-send-email-karim.eshapa@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karim Eshapa <karim.eshapa@gmail.com>
Date: Mon, 24 Apr 2017 21:54:42 +0200

> On  Mon, 24 Apr 2017 14:18:58 -0400 (EDT), David Miller wrote:
>> Mon, 24 Apr 2017 19:49:39 +0200, Karim Eshapa wrote:
>>>
>>> static char pointer creates two variables in final assembly.
>>> static string and pointer to it according to
>>> Jeff Garzik janitors TODO.
>>
>> Instead of trusting some document written more than 10 years ago on
>> the internet, why don't you build the source file in question and take
>> a look at what actually happens?
>>
> 
> I've just dumped the assembly and symbols. I didn't find 
> extraordinary difference between the two strings.
> sorry for that, but why is that still there in 
> TODO kerneljanitors at kernelnewbies.

Because nobody is updating the documentation.
