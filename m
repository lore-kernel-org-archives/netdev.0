From: Daniele Venzano <webvenza@libero.it>
Subject: Re: [stable] [BK PATCHES] 2.6.x net driver oops fixes
Date: Fri, 11 Mar 2005 20:29:50 +0100
Message-ID: <c37a8fd17af92b648c6474904e0003c0@libero.it>
References: <422F59E8.2090707@pobox.com> <20050310202548.GV5389@shell0.pdx.osdl.net> <4230AE24.602@pobox.com> <20050310213917.GW5389@shell0.pdx.osdl.net>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>
In-Reply-To: <20050310213917.GW5389@shell0.pdx.osdl.net>
To: Chris Wright <chrisw@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 10/mar/05, at 22:39, Chris Wright wrote:

> * Jeff Garzik (jgarzik@pobox.com) wrote:
>> Chris Wright wrote:
>>> * Jeff Garzik (jgarzik@pobox.com) wrote:
>>>
>>>
>>>> This will update the following files:
>>>>
>>>> drivers/net/sis900.c    |   41 
>>>> +++++++++++++++++++++--------------------
>>>> drivers/net/via-rhine.c |    3 +++
>>>
>>>
>>> The via-rhine fix is already in the stable queue.  But the sis900 
>>> oops
>>> fix does not apply to the stable tree.  It relies on a few 
>>> intermediate
>>> patches.  Appears to still be an issue for the older version which 
>>> is in
>>> 2.6.11.  Here's a stab at a backport.  Would you like to 
>>> review/validate
>>> or drop this one?
>>
>> The backport looks correct to me, though it would be nice to get a
>> via-rhine owner to ACK the patch before it goes in...
>
> OK, thanks.  ITYM sis900 maintainer, is that still Ollie Lho as listed 
> in
> MAINTAINERS (that's looking old)?

I have been acting maintainer for more than a year now, and I'm 
completely fine with the patch.

A lot of time ago (2.6.6) I proposed a patch to update MAINTAINERS, but 
Jeff said he wanted to wait some time. I don't know if such change is 
now possible/wanted.
AFAIK Ollie's email address bounces.

--
Daniele Venzano
http://www.brownhat.org
