From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] netpoll: warn when there are spaces in parameters
Date: Thu, 18 Mar 2010 10:02:37 +0800
Message-ID: <4BA189BD.7070400@redhat.com>
References: <20100317101635.5948.23485.sendpatchset@localhost.localdomain> <201003171158.49549.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Frans Pop <elendil@planet.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201003171158.49549.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frans Pop wrote:
> Amerigo Wang wrote:
>> +               if (*cur == ' ' || *cur == '\t')
>> +                       printk(KERN_INFO "%s: warning: white spaces"
>> +                                       "are not allowed.\n", np->name);
>>
> 
> The term "white spaces" not correct. Please change the message to
> "whitespace is not allowed".
> 
> Also, it's normally not necessary to close kernel messages with a period; 
> most kernel messages do not have a closing period. Messages are not 
> sentences and the periods only help increase the kernel size.
> 

Ok, I will update it.

Thanks.
