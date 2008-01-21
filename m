From: nigel@crca.org.au
Subject: Re: 2.6.24 regression: reference count leak in PPPoE
Date: Mon, 21 Jan 2008 00:33:32 +0000
Message-ID: <20080121003332.91yx02wc0sgk0sg4@mail.crca.org.au>
References: <200801202053.30386.ak@suse.de>
	<20080120200109.GA31876@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crca.org.au ([67.207.131.56]:58516 "EHLO crca.org.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754671AbYAUAof convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 19:44:35 -0500
In-Reply-To: <20080120200109.GA31876@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Quoting Ingo Molnar <mingo@elte.hu>:

>
> * Andi Kleen <ak@suse.de> wrote:
>
>> My workstation running 2.6.24-rc8 just hung during shutdown with an
>> endless (or rather I didn't wait more than a few minutes) loop of
>>
>> unregister_netdev: waiting for ppp-device to become free. Usage count
>> = 1
>>
>> ppp-device was an active PPPoE device.
>>
>> No more information currently.
>
> i've seen such problems (locked up box with endless loop of usage count
> == 1) with pppoe in the past, and it seemed to be related to dynamic
> IPs. (i saw that well before 2.6.24 - reported it once to davem)
>
> It seems to have stopped when i stopped using ipsec and started using
> vpnc. (but no firm info - this was sporadic - happened every few months
> or so) Are you using ipsec and dynamic IPs by any chance?

This isn't PPPoE specific. It has also been seen with e1000, madwifi  
and an intel based card. It was introduced by a Jan 10 commit post rc7  
(sorry, don't have the details right now - my laptop died yesterday).  
A bugzilla has already been opened.

Nigel

----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

