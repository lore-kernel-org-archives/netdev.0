From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH/RFC] Adding IP(v6) address with scope link creates global
 address
Date: Mon, 07 Dec 2009 12:18:06 -0500
Message-ID: <4B1D38CE.1060001@hp.com>
References: <20091125135945.GA7195@amd64.fatal.se> <20091207134108.GA23087@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:28963 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964797AbZLGRSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 12:18:32 -0500
In-Reply-To: <20091207134108.GA23087@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

Andreas Henriksson wrote:
> Hello again!
> 
> Replying to myself (see http://www.spinics.net/lists/netdev/msg113943.html)
> and attaching an untested patch to see if this sparks more interest.
> 
> On Wed, Nov 25, 2009 at 02:59:45PM +0100, Andreas Henriksson wrote:
>> "Jedasothi" reported problems setting scope with iproute on newly added
>> ipv6 addresses in:
>> https://bugs.launchpad.net/ubuntu/+source/iproute/+bug/487745
>>
>>> To reproduce bug run
>>> ip addr add '::4/64' scope link dev eth0
>>>
>>> This results in a line seen with
>>> ip addr show eth0
>>> inet6 ::4/64 scope global tentative
>>>
>>> The label "global" is seen instead of "link".
> 
> I'd appreciate if someone could review and test this:

I tried the patch quickly since I was curious why this is a problem, but
it didn't work exactly right.  I could post an update, but I'm not sure
this is the right thing to do - ::4 isn't a link-local address, and other
parts of the network stack (and other systems) aren't going to treat it as
such.

Maybe the submitter can explain exactly how this is breaking something?

Thanks,

-Brian
