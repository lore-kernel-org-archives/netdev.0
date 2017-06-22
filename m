From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: Re: [PATCH] netxen: Fix a sleep-in-atomic bug in
 netxen_nic_pci_mem_access_direct
Date: Thu, 22 Jun 2017 18:52:45 +0800
Message-ID: <ab2ea6f6-330f-068a-e9dd-d2803e203b45@163.com>
References: <1497840533-4894-1-git-send-email-baijiaju1990@163.com>
 <20170620.133530.1607963470682255531.davem@davemloft.net>
 <87d19xooo0.fsf@purkki.adurom.net> <594A131F.9040300@163.com>
 <8737atv4pm.fsf@kamboji.qca.qualcomm.com>
 <20170622060809.jvnuewiicuwtlzb4@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, manish.chopra@cavium.com,
        rahul.verma@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:44383 "EHLO m12-15.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753107AbdFVKxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 06:53:09 -0400
In-Reply-To: <20170622060809.jvnuewiicuwtlzb4@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/6/22 14:08, Dan Carpenter wrote:
> We should probably add a might_sleep() to ioremap() to prevent these
> bugs in the future.
I think it is right to do this.
And it will be very useful to summarize common kernel interface 
functions which may sleep into a list. When writing a new driver, the 
developer can refer to this list to reduce or avoid sleep-in-atomic bugs.

>
> This bug is eight years old.  You can report it, but it's going to hard
> to get anyone to fix it.  I sometimes ignore ancient bugs.  On the other
> hand, netxen is fairly well supported so it doesn't hurt to try.
>
> I try to report bugs as soon as they are introduced.  I report it to
> the author and CC the relevant list.  If people don't respond to my
> email after a month then I complain again.
>
> regards,
> dan carpenter
>

Thanks for your helpful advice.

Thanks,
Jia-Ju Bai
