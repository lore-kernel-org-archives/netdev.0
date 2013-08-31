From: Fernando Gont <fernando@gont.com.ar>
Subject: Re: Fwd: RFC 6980 on Security Implications of IPv6 Fragmentation
 with IPv6 Neighbor Discovery
Date: Sat, 31 Aug 2013 02:22:51 -0300
Message-ID: <52217DAB.5090502@gont.com.ar>
References: <20130813221321.AEA1AB1E003@rfc-editor.org> <520B3D81.9070506@gont.com.ar> <20130814230617.GA13066@order.stressinduktion.org> <520C7519.1010000@gont.com.ar> <20130815100407.GA18564@order.stressinduktion.org> <CAOp4FwRx3c3deHXupWg3S0aWe4ZJnCT9ORKCWRvUUuxxt1gneQ@mail.gmail.com> <20130815102507.GA24122@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Loganaden Velvindron <loganaden@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:36722 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956Ab3HaHOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 03:14:46 -0400
In-Reply-To: <20130815102507.GA24122@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2013 07:25 AM, Hannes Frederic Sowa wrote:
> 
>> 3) What will/could break with this diff in a production environment ?
> 
> RA messages could get fragmented if a speaker puts lots of options in it. I
> hope all RA speakers already spread the options over multiple RAs, but I don't
> know. In case the RA is fragmented it will now be dropped silently.

My understanding is that some implementations were already dropping
fragmented RAs... so you better avoid fragmentation. Put another way:
you're already in trouble if you rely on fragmented ND messages.

Cheers,
-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
