From: Shailabh Nagar <nagar@watson.ibm.com>
Subject: Re: [Patch 5/8] generic netlink interface for delay accounting
Date: Thu, 30 Mar 2006 11:24:38 -0500
Message-ID: <442C0646.3090308@watson.ibm.com>
References: <442B271D.10208@watson.ibm.com> <442B2BB6.9020309@watson.ibm.com> <20060329210406.08d1c929.akpm@osdl.org> <20060330061005.GA18387@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tgraf@suug.ch, hadi@cyberus.ca
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932194AbWC3QYm@vger.kernel.org>
To: balbir@in.ibm.com
In-Reply-To: <20060330061005.GA18387@in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Balbir Singh wrote:

>Hi, Andrew
>
>
>On Wed, Mar 29, 2006 at 09:04:06PM -0800, Andrew Morton wrote:
>  
>
>>Shailabh Nagar <nagar@watson.ibm.com> wrote:
>>    
>>
>>>delayacct-genetlink.patch
>>>
>>>Create a generic netlink interface (NETLINK_GENERIC family),
>>>called "taskstats", for getting delay and cpu statistics of
>>>tasks and thread groups during their lifetime and when they exit.
>>>
>>>
>>>
>>>      
>>>
<snip>

>>>+
>>>+static int __init taskstats_init(void)
>>>+{
>>>+	if (genl_register_family(&family))
>>>+		return -EFAULT;
>>>      
>>>
>>EFAULT?
>>    
>>
>
>It shouldn't be (Shailabh please comment). We will fix it.
>  
>
Sorry, it should return the  value returned by genl_register_family.

I copied the code from net/tipc/netlink.c
where a similarly erroneous errno is being used. We'll submit a fix
for that as well.

--Shailabh
