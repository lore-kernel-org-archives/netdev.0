From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH V3] wanrouter: Remove it and the drivers that depend on
 it
Date: Fri, 11 Jan 2013 01:28:04 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1301110118390.3948@nerf07.vanv.qr>
References: <1352846164.17444.16.camel@joe-AO722> <20121113.182215.2003568859498195687.davem@davemloft.net> <CAP=VYLqiLpVn99bp08gkSQ+jLFiw8T7vsohJ6e+TdzOtyDwKBQ@mail.gmail.com> <20121113.204437.197646115673556624.davem@davemloft.net> <20121114060759.GA17128@windriver.com>
 <20121114152339.GA22933@windriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, joe@perches.com,
	netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:60943 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827Ab3AKA2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 19:28:07 -0500
In-Reply-To: <20121114152339.GA22933@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2012-11-14 16:23, Paul Gortmaker wrote:
>> > 
>> > Please repost with the HTML stuff removed.
>> 
>> Ah crap.  I'd replied via gmail ; today and occasionally in the past as
>> a convenient short cut when not reading netdev with a "normal" MUA.  And
>> this is not the 1st time gmail has randomly decided to be "helpful" by
>> mangling plain text like this.  Well, I'll be having no more of that BS.
>
>I was curious to better figure out what triggered this, now that it
>isn't 1AM.  It seems the original wasn't plain text, and that gmail
>didn't know what else to do with the content from your message when it
>arrived as base64 encoded.
>http://marc.info/?l=linux-netdev&m=135284894104364&w=2

I only wonder which component is at fault here, the producer side (it
gives the following headers),

 Content-Type: Text/Plain; charset=iso-8859-7
 Content-Transfer-Encoding: base64
 (and the _absence_ of any MIME chunkwrapping)

or the receiver side. (Al)Pine and derivates displays the message
fine, marc.info does not, and gmail presents the body after literally
taking a stab at it.
