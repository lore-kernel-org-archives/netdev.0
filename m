From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE]: First release of nftables
Date: Wed, 18 Mar 2009 09:21:26 +0100
Message-ID: <49C0AF06.2000803@trash.net>
References: <49C078B6.4020603@trash.net> <alpine.LSU.2.00.0903180847180.8376@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>, tgraf@suug.ch
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0903180847180.8376@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Wednesday 2009-03-18 05:29, Patrick McHardy wrote:
>   
>> - logging:  logging using the nf_log mechsism using the primary backend.
>>
>>  Usage: "log [ prefix "prefix" ] [ group NUM ] [ snaplen NUM ]
>>              [ queue-threshold NUM ]
>>     
>
> Hm, how does one do traditional logging to syslog? Some of us just do
> logging for debugging purposes and would not otherwise need the full-blown
> nf_log solution - let alone there be enough space on some constrained
> hardware for a thorough logger (say, WRT54).
>   

Its using the primary backend. You can load "ipt_LOG".

>> - limit: might be broken currently
>>
>>  Usage: "limit rate RATE/time-unit"
>>     
>
> Does it use the old limit code (which has numerous accuracy problems
> it seems), or will it magically make use of the rate estimator?
>   

It doesn't use either, but it won't have the old accuracy problems
either once
its fixed.


>> git://git.netfilter.org/nftables.git
>>     
>
> Missing a tag too, I think you (Patrick) can add it still :)
>   
I'll tag it at the first version bump.

>> The kernel tree will eventually also move to netfilter.org, currently
>> the git daemon is unable to handle it because of memory shortage.
>>
>> Ths source code is considered alpha quality and is not meant for users
>> at this time, it will spew quite a lot of debugging messages and
>> definitely has bugs. Nevertheless, all of the basic features and most
>> of the rest should work fine, the last crash has been several months
>> ago. The two most noticable things that currently don't work is
>> numerical argument parsing for arguments that have more specific types
>> (f.i. port numbers), as well as reconstruction of the internal
>> representation of sets and dictionaries using ranges. Both will be
>> fixed shortly.
>>     
>
> How about storing the actual text the user inputed in something like
> an -m comment, as an aid to the user for finding his rules again
> after they have been optimized internally?
Thats not really necessary so far, and I don't want to in any case. If
someone
really wants this (and I very much question the need), it can be done in
userspace.
