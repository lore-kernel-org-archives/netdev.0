From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Tue, 12 Mar 2013 09:53:43 -0600
Message-ID: <513F4F87.5040308@genband.com>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com> <1362888229.4051.2.camel@edumazet-glaptop> <CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com> <1362891937.4051.25.camel@edumazet-glaptop> <20130310004904.de508bfa.billfink@mindspring.com> <1362894876.4051.27.camel@edumazet-glaptop> <513F3BE1.2080409@genband.com> <20130312154245.GA13101@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Bill Fink <billfink@mindspring.com>, Vimal <j.vimal@gmail.com>,
	netdev@vger.kernel.org, shemminger <shemminger@vyatta.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og126.obsmtp.com ([64.18.2.206]:41061 "EHLO
	exprod7og126.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753910Ab3CLPys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 11:54:48 -0400
In-Reply-To: <20130312154245.GA13101@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/2013 09:42 AM, Thomas Graf wrote:
> On 03/12/13 at 08:29am, Chris Friesen wrote:
>> The only problem I see is that you can't set the multiplier with a
>> new tool and then query the rate with old tools.
>>
>> But you're going to run into that problem with the old tools no
>> matter what you do--and not doing anything is a crappy option as
>> well.
>>
>> Some kind of multiplier or shift makes as much sense as anything
>> else. With old tools you get current behaviour, with new tools you
>> can specify a multiplying factor to trade off resolution vs
>> precision.
>
> The introduction of a shift operator or multiplier introduces
> inprecision. I'd much rather see new 64bit Netlink attributes
> that, if present, replace the old rate values and statistics.

I have strong opinions either way, but I don't think "imprecision" is a 
problem in practice.

With the shift/multiplier we would have 32 bits of precision.  Do you 
really expect that someone will care about the difference between 
8589934592 and 8589934593?  Or the difference between 40000000000 and 
40000000010?

Chris
