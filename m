From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] netconsole: fix NULL pointer dereference
Date: Thu, 24 Oct 2013 20:22:27 +0200
Message-ID: <52696563.1060507@redhat.com>
References: <1382533489-19248-1-git-send-email-nikolay@redhat.com> <20131024102147.GD16787@redhat.com> <AE90C24D6B3A694183C094C60CF0A2F6026B73A9@saturn3.aculab.com> <20131024.135614.1725589105857635534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, vfalico@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52066 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752724Ab3JXSWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 14:22:33 -0400
In-Reply-To: <20131024.135614.1725589105857635534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2013 07:56 PM, David Miller wrote:
> From: "David Laight" <David.Laight@ACULAB.COM>
> Date: Thu, 24 Oct 2013 11:39:02 +0100
> 
>>>> Taking the spinlock seems like the cleanest way to insure there's noone
>>>> running in parallel, but I'm open to suggestions as I'm not satisfied with
>>>> the looks of this. I'll prepare a net-next patchset for netconsole soon to
>>>> clean it up properly, all of these can be easily simplified.
>>>
>>> First when I've seen 'spin_lock(); a = 1; spin_unlock()' I've thought
>>> "WTF?", however indeed it will stop us racing with write_msg().
>>
>> Ditto - might be worth saying:
>>     /* Acquire lock to wait for any write_msg() to complete. */
> 
> Something this subtle definitely requires a comment.
> 
Okay, thank you all for the reviews. I will re-submit a v2 with
the comment edited.

Nik
