From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net/stable] ipv6/exthdrs: accept tlv which includes only
 padding
Date: Sat, 7 Sep 2013 23:34:45 +0200
Message-ID: <20130907213445.GB1442@minipsycho.orion>
References: <1378476145-6282-1-git-send-email-jiri@resnulli.us>
 <alpine.LNX.2.00.1309071427120.1262@heraclitus>
 <20130907154602.GA1442@minipsycho.orion>
 <alpine.LNX.2.00.1309071819310.24145@heraclitus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eldad Zack <eldad@fogrefinery.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:48413 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720Ab3IGVet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 17:34:49 -0400
Received: by mail-ea0-f169.google.com with SMTP id k11so2358809eaj.0
        for <netdev@vger.kernel.org>; Sat, 07 Sep 2013 14:34:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1309071819310.24145@heraclitus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Sep 07, 2013 at 06:46:12PM CEST, eldad@fogrefinery.com wrote:
>
>
>On Sat, 7 Sep 2013, Jiri Pirko wrote:
>
>> Sat, Sep 07, 2013 at 02:31:36PM CEST, eldad@fogrefinery.com wrote:
>> >
>> >Hi Jiri,
>> >
>> >On Fri, 6 Sep 2013, Jiri Pirko wrote:
>> >
>> >> In rfc4942 and rfc2460 I cannot find anything which would implicate to
>> >> drop packets which have only padding in tlv.
>> >
>> >NAK from my side.
>> >Please read RFC4942 2.1.9.5 "Misuse of Pad1 and PadN Options".
>> 
>> I did.
>> 
>> >
>> >While it doesn't specifically discusses this corner case, you can 
>> >understand from "There is no legitimate reason for padding beyond the 
>> >next eight octet..." that there's also no legitimate reason for an 
>> >option header containing only padding.
>> 
>> Okay. I'm glad you agree with me and that we both understand the rfc the
>> same way. And since the rfc does not say that "here's no legitimate
>> reason for an option header containing only padding", this should be
>> possible. I say we respect rfc and do not add stronger restrictions than
>> it dictates. No need for them.
>
>Strictly speaking, this RFC is informational, so it is doesn't dictate 
>per se. I hope you don't suggest removing the other checks as well...

If there are some that just plainly assumes something and does
restrictions without any solid argument, yes remove them.

>
>> >I can't imagine a sane use-case for this.
>> 
>> rfcs are not about sanity...
>
>Great, we're in agreement again :) But I think the networking code is 
>or should be.
>What IPv6 stack would generate such a packet, given that the only usage 
>of the padding options is to align other options?

But why not? I do not see anything evil about that. And rfc allows it.

>Why should I accept a packet which is most likely an artificially 
>crafted packet (RFC 3514)?
>
>Cheers,
>Eldad
>
