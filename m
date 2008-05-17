From: James Cammarata <jimi@sngx.net>
Subject: Re: [PATCH updated] net: add ability to clear per-interface	network
 statistics via procfs
Date: Sat, 17 May 2008 10:06:13 -0500
Message-ID: <482EF465.2050205@sngx.net>
References: <482DA5B6.1020606@sngx.net> <20080516.130004.18881610.davem@davemloft.net> <482DE9EC.3060803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757751AbYEQPFl@vger.kernel.org>
In-Reply-To: <482DE9EC.3060803@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> We saw your initial patch posting, you don't need to send this
>> again.
>>
>> netdev added to CC:

I had regenerated the diff against .25.4 and made a few changes so I resubmitted.
Sorry if I made it seem like I was spamming the patch.

> I don't wish to suggest I don't like the change - I've used similar 
> features on "other oses" in the past, but when something like this has 
> come-up in the past, haven't there been concerns about MIBs and SNMP and 
> whatnot?
> 
> rick jones
> ftp://ftp.cup.hp.com/dist/networking/tools - beforeafter - subtract one 
> set of stats from another...

Yes, this would definitely be a caveat, as it could cause problems if the software
takes a baseline once, and calculates differences from that ever after.  For others,
it would cause a hiccup where stats show as being negative for one period.

However, I think the benefit of being able to troubleshoot issues on an interface 
in a non-invasive manner outweigh the downside here.  Like you say, this ability 
is already found elsewhere, most namely in network devices like Ciscos, and the 
concern for clearing stats there does not exist.
