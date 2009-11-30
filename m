From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: net 00/05: routing based send-to-self implementation
Date: Mon, 30 Nov 2009 11:37:31 -0800
Message-ID: <4B141EFB.4070409@candelatech.com>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet> <m1r5rf4xm9.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60226 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbZK3Tha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 14:37:30 -0500
In-Reply-To: <m1r5rf4xm9.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2009 11:32 AM, Eric W. Biederman wrote:
> Patrick McHardy<kaber@trash.net>  writes:
>
>> These patches are yet another attempt at adding "send-to-self" functionality,
>> allowing to send packets between two local interfaces over the wire. Unlike
>> the approaches I've seen so far, this one is purely routing based.
>> Especially the oif classification should also be useful for different setups.
>
> Why not put each physical interface in a different network namespace?
> That should work with no changes today.

This doesn't work if you want to have one application manage lots of interfaces
and send traffic between these interfaces.  Certainly there are use-cases that
can use multiple name-spaces, but it's nice to have the option not to use them
as well.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

