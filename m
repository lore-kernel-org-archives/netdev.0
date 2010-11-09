From: Ben Greear <greearb@candelatech.com>
Subject: Re: Networking hangs when too many parallel requests are made at
 once
Date: Tue, 09 Nov 2010 14:14:58 -0800
Message-ID: <4CD9C7E2.6050909@candelatech.com>
References: <AANLkTikuCj=saH34dyO6xnU-y8rWv63hJaqowZ0ACLzk@mail.gmail.com> <AANLkTinRo_ozWFCYYqanOh0YrTJ6+KadutG2j7T726dY@mail.gmail.com> <4CD99E20.4060307@candelatech.com> <AANLkTinz6C4s3wX7t6CsE2bzZ2adCoi0RAcqvpEFE2GV@mail.gmail.com> <4CD9B09B.8040906@candelatech.com> <AANLkTinu4=Ox_vA_yr7vbdbcqr4P7oS+zMX_yaXhK4E9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Luke Hutchison <luke.hutch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52489 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163Ab0KIWPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 17:15:00 -0500
In-Reply-To: <AANLkTinu4=Ox_vA_yr7vbdbcqr4P7oS+zMX_yaXhK4E9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2010 01:17 PM, Luke Hutchison wrote:

> On Tue, Nov 9, 2010 at 3:35 PM, Ben Greear<greearb@candelatech.com>  wrote:
>> And, a network capture of your system going into this state might
>> be useful.  I'd try to disable your wireless NIC entirely and focus
>> on debugging the wired NIC as that is usually easier to debug.
>
> Sure -- a wireshark trace is here: http://web.mit.edu/~luke_h/www/trace.bz2
>
> In this particular trace, I opened about 20 browser tabs at once.
> They all locked up after about 5 seconds.  A few of them loaded some
> more content after a minute or two.  A minute or two later, I killed
> them all.  In this particular example, pinging to a specific domain
> name continued to work (it doesn't always), although I couldn't get
> content from the domains in question: e.g. I could ping google.com,
> but opening a new tab and trying to visit google.com caused the new
> tab to hang too.

Have you tried using a different DNS server (open-dns?), or maybe a caching one one
your local machine?  Maybe some part of your network is throwing away
some of your DNS requests since you send so many at once?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

