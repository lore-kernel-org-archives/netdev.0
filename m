From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: [PATCH 1/4] Prefix List against 2.5.73
Date: Wed, 16 Jul 2003 17:06:07 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3F15E86F.2030707@us.ibm.com>
References: <200307162341.DAA12466@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, davem@redhat.com, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307162341.DAA12466@dub.inr.ac.ru>
List-Id: netdev.vger.kernel.org

This is sort of what I had originally, so I should be able to change
it to do this quite easily. I didn't like the earlier suggestion of
using existing RTM_xxxLINK with RTM_xxxIFACE (since it was dev generic),
but having a new interface RTM_xxxIFACE sounds good to me.

Thanks,

- KK

kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> 
>>My suggestion is:
>> - create L3 per-interface RTM, say, RTM_xxxIFACE.
>> - provide inet_device / inet6_dev things via this RTM.
>>    e.g. per-interface statistics, flags etc.
> 
> 
> I agree for all 100%. I understand your attitude now.
> 
> Alexey
> 

