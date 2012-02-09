From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 00/50] set addr_assign_type to NET_ADDR_RANDOM if
 a random mac address get assigned to a netdevice
Date: Thu, 09 Feb 2012 13:37:24 -0500 (EST)
Message-ID: <20120209.133724.45349929204452445.davem@davemloft.net>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
	<20120208.182942.1223790992368933837.davem@davemloft.net>
	<201202091318.36264.danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201202091318.36264.danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Thu, 9 Feb 2012 13:18:35 +0100

> On Donnerstag, 9. Februar 2012, David Miller wrote:
>> 50 patches is way too many patches to submit and expect people
>> to review at one time.
>>
>> You must do one of two things:
>>
>> 1) Condense the series down to a smaller number of more managable
>>    patches.  Perhaps combine all the completely trivial conversion
>>    cases into one single patch, and post the non-trivial cases
>>    seperately.
>>
>> 2) Only submit a few of these changes at a time, not all at once.
>>
>> It's your choice, but what you did here is unacceptable.
> 
> Could you at least comment on these points from the cover letter, before I 
> change/update the patches?
> 
> - Should NET_ADDR_RANDOM get reset (to NET_ADDR_PERM) if the MAC address
>   get changed via SIOCSIFHWADDR/.ndo_set_mac_address and was random before?

Probably, yes.

> - Would it make sense to add a new state (e.g. NET_ADDR_USERSPACE)
>   if the net address get changed via SIOCSIFHWADDR/.ndo_set_mac_address 
>   from userspace?

I suspect this is not useful.
