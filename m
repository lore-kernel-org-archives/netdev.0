From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: bonding and IPv6 "doesn't work"?
Date: Tue, 12 Jul 2011 11:15:22 -0600
Message-ID: <4E1C812A.4080701@genband.com>
References: <4E1C70D5.6060806@wpkg.org> <20110712161455.GD909183@jupiter.n2.diac24.net> <4E1C756C.2010700@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Tomasz Chmielewski <mangoo@wpkg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og121.obsmtp.com ([64.18.2.20]:39076 "EHLO
	exprod7og121.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848Ab1GLRQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 13:16:53 -0400
In-Reply-To: <4E1C756C.2010700@wpkg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/2011 10:25 AM, Tomasz Chmielewski wrote:
> On 12.07.2011 18:14, David Lamparter wrote:

>> Your bonding peer is probably looping those
>> packets back on the other link, most likely because...
>>
>>> Bonding Mode: load balancing (round-robin)
>>
>> ... most likely because you maybe have a switch on the other side, and
>> that switch expects you to do 802.3ad?
>
> It's a virtual machine, so the host shouldn't know or care much about
> 802.3ad (I think!).

I suspect that connecting multiple links of a bond to the same unmanaged 
switch (or virtual bridge) is going to confuse things.

Try using multiple virtual bridges instead, one for each slave in the 
bond.  That way they won't interfere with each other.

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
