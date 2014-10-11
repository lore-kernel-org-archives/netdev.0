From: David Miller <davem@davemloft.net>
Subject: Re: Netlink mmap tx security?
Date: Sat, 11 Oct 2014 19:09:57 -0400 (EDT)
Message-ID: <20141011.190957.1296445052360891885.davem@davemloft.net>
References: <CALCETrWsCqy7KEKPTOeHjrO1c2JE1E_seO_J+yA=sYFhS11NXQ@mail.gmail.com>
	<CALCETrVuREGVKwrni61DEg=Tgjc7x41WYtrEiDMqMvwVFXfybw@mail.gmail.com>
	<CALCETrWfQe5H2Ht7cjCQLfUw+XUcRvga_H93esaWpAp37=noZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, kaber@trash.net,
	netdev@vger.kernel.org
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40551 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbaJKXJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2014 19:09:58 -0400
In-Reply-To: <CALCETrWfQe5H2Ht7cjCQLfUw+XUcRvga_H93esaWpAp37=noZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 11 Oct 2014 15:29:17 -0700

> On May 12, 2014 3:08 PM, "Andy Lutomirski" <luto@amacapital.net> wrote:
>>
>> [moving to netdev -- this is much lower impact than I thought, since
>> you can't set up a netlink mmap ring without global CAP_NET_ADMIN]
> 
> Did anything ever happen here?  Despite not being a privilege
> escalation in the normal sense, it's still a bug, and it's still a
> fairly easy bypass of module signatures.

We definitely still need to address this, and since Patrick has still
not responded on this issue after being given 5 months to do so, the
only reasonable path is to get rid of this feature altogether.

Thanks for reminding me.
