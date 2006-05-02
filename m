From: David Vrabel <dvrabel@cantab.net>
Subject: Re: IP1000 gigabit nic driver
Date: Tue, 02 May 2006 01:36:30 +0100
Message-ID: <4456A98E.9020108@cantab.net>
References: <84144f020604280358ie9990c7h399f4a5588e575f8@mail.gmail.com> <20060428113755.GA7419@fargo> <Pine.LNX.4.58.0604281458110.19801@sbz-30.cs.Helsinki.FI> <1146306567.1642.3.camel@localhost> <20060429122119.GA22160@fargo> <1146342905.11271.3.camel@localhost> <1146389171.11524.1.camel@localhost> <44554ADE.8030200@cantab.net> <4455F1D8.5030102@cantab.net> <20060501203847.GA7419@electric-eye.fr.zoreil.com> <20060501204150.GC1450@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	david@pleyades.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from pythagoras.zen.co.uk ([212.23.3.140]:13512 "EHLO
	pythagoras.zen.co.uk") by vger.kernel.org with ESMTP
	id S932335AbWEBAgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 20:36:43 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20060501204150.GC1450@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> On Mon, May 01, 2006 at 10:38:47PM +0200, Francois Romieu wrote:
> 
> 
>>>-/* Minimum number of miliseconds used to toggle MDC clock during
>>>+/* Minimum number of nanoseconds used to toggle MDC clock during
>>>  * MII/GMII register access.
>>>  */
>>>-#define         IPG_PC_PHYCTRLWAIT           0x01
>>>+#define		IPG_PC_PHYCTRLWAIT_NS		200
>>
>>I would have expected a cycle of 400 ns (p.72/77 of the datasheet)
>>for a 2.5 MHz clock. Why is it cut by a two factor ?
> 
> 
> 200 ns high + 200 ns low = 400 ns clock period?

Yes.

David
