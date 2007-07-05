From: Patrick McHardy <kaber@trash.net>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Thu, 05 Jul 2007 15:37:34 +0200
Message-ID: <468CF41E.4020409@trash.net>
References: <1183492286.4021.21.camel@johannes.berg>	 <468BAADC.4030203@trash.net> <1183558702.3812.33.camel@johannes.berg>	 <468BAF10.6080208@trash.net> <1183559883.3812.42.camel@johannes.berg>	 <468BB327.5050709@trash.net> <1183561006.3812.47.camel@johannes.berg>	 <468BB5F8.3080908@trash.net> <1183561713.9662.5.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64244 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755435AbXGENh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 09:37:58 -0400
In-Reply-To: <1183561713.9662.5.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Wed, 2007-07-04 at 17:00 +0200, Patrick McHardy wrote:
> 
> 
>>Not by itself probably but a user could DoS your wireless connectivity
>>this way.
> 
> 
> Hmm, if anything then not the connectivity but rather the MLME i.e. it
> won't do roaming properly maybe. Maybe we should then have a way to say
> that somebody only wants to receive messages from privileged users, that
> way the MLME process wouldn't be affected.


Earlier filtering makes sense, especially for userspace. The other
part exceeds my wireless knowledge :)

>>I'm not sure, it would probably also have to be called when userspace
>>unsubscribes from a group, no?
> 
> 
> No actually having that hook means I can do without multicast groups by
> just publishing that "send configuration requests to pid N" where N is
> either 0 (in-kernel MLME) or something else (userspace MLME); I just
> didn't know the hook existed.


Even better. Publishing that to userspace is going to be racy though.

> Not that we shouldn't fix the multicast issues anyway though the one
> from this particular thread wouldn't be too interesting right now until
> somebody needs userspace to multicast; the other three patches still
> should be done now before there are more generic netlink multicast
> users.


The genetlink stuff defintely makes sense. I'll have a closer look at
your patches this weekend.

