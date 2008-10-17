From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/7] netns ebtables: part 1
Date: Fri, 17 Oct 2008 13:57:55 +0200
Message-ID: <48F87DC3.2090608@trash.net>
References: <20081015042014.GE24058@x200.localdomain> <48F73DA3.1030401@trash.net> <20081016193955.GA26245@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081016193955.GA26245@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> On Thu, Oct 16, 2008 at 03:12:03PM +0200, Patrick McHardy wrote:
>>> @@ -6,5 +6,6 @@
>>>   struct netns_xt {
>>>  	struct list_head tables[NPROTO];
>>> +	struct list_head ebt_tables;
>> This could just use tables[NFPROTO_BRIDGE].
> 
> Good!
> 
> [drops some code]
> 
> I do wonder why these new numbers a) contain holes and b) exported in
> headers.

Its used by userspace. We had to keep the old values for
compatibility.
