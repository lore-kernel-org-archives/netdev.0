From: jamal <hadi@cyberus.ca>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 28 Nov 2009 12:36:14 -0500
Message-ID: <1259429774.3864.41.camel@bigi>
References: <db81a9a20911230443h443b3c2l8fab5aef7b09cfa@mail.gmail.com>
	 <1259137434.9191.3.camel@nienna.balabit>
	 <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
	 <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi>
	 <20091128151515.GA20476@sch.bme.hu>  <4B1145F1.3090704@trash.net>
	 <1259424278.3864.16.camel@bigi>  <4B1158CE.90803@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	KOVACS Krisztian <hidden@balabit.hu>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:39568 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631AbZK1RgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 12:36:11 -0500
Received: by qyk32 with SMTP id 32so970325qyk.4
        for <netdev@vger.kernel.org>; Sat, 28 Nov 2009 09:36:17 -0800 (PST)
In-Reply-To: <4B1158CE.90803@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-11-28 at 18:07 +0100, Patrick McHardy wrote:

> Right, its source validation. But the setup is valid, its asking for
> specifically marked packets to be delivered locally for transparent
> proxying. There's no requirement that rules using marks must resolve
> to RTN_UNICAST.

True, but that requirement is needed for source validation;->
i.e it is source address validation imposing the requirement
that we must have a RTN_UNICAST route. The tproxy iproute setup entered
a route that was not RTN_UNICAST. I think that the packet deserves to be
beaten with a club then dropped hard into an abyss (Feel free to come up
with  something more medievial to do to it Patrick;-> )
It doesnt make sense to have a source address that is not unicast
belonging to a host or pretending to belong to a host.
So i didnt introduce that logic thats causing this pain.
If it worked before it was hack or fluke imo ;-> If we think that
source address validation needs to check for something else
additionally, i think thats a separate topic (but doesnt
seem worth a change)

cheers,
jamal

