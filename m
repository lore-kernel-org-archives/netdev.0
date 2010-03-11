From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Thu, 11 Mar 2010 12:25:24 -0700
Message-ID: <4B9943A4.8040606@redfish-solutions.com>
References: <201001121432.43301.schmto@hrz.tu-chemnitz.de>	<20100112.121607.39835310.davem@davemloft.net>	<4B4CE2B8.1040702@redfish-solutions.com> <20100112.130355.144803575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torsten.schmidt@s2006.tu-chemnitz.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:32888 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756338Ab0CKTZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 14:25:31 -0500
In-Reply-To: <20100112.130355.144803575.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2010 02:03 PM, David Miller wrote:
> From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
> Date: Tue, 12 Jan 2010 12:59:36 -0800
> 
>> What has changed is how network equipment is required to interpret
>> the meaning of those bits.
>>
>> Even if we pass the bits "as is" to the network, if the network is
>> applying entirely new semantics (and when I say "entirely new", I
>> mean those mandated since 1998), then compatibility in the host
>> kernel API doesn't matter a hoot since the packets will still be
>> handled by every transited router according to the modern semantics.
> 
> People really don't assign global meaning to bits set by applications
> in the TOS field.
> 
> What they do is they have a set of semantics inside of their cloud of
> routers and switch points for diffserv, and when packets come in the
> TOS field is rewritten to whatever scheme is being used inside of that
> cloud.
> 
> And the diffserv bits only have meaning and effect within that cloud.
> 
> So really, having a syscall that sets the TOS bits exactly by
> applications is just fine.
> 
> People are doing diffserv right now with Linux and have done so
> for years.

Sorry about coming back to this weeks later... but I hadn't seen RFC 4594 previously.

What if boxes (i.e. the OS) and applications can preconfigured to use RFC-4594 guidelines by default, and varying from that required the administrator to make specific changes?

I agree with the notion that certain values should be set side-wide (or at least system-wide) to prevent malicious users from exploiting QoS...  that's why I've been advocating for QoS settings to be specified in a system configuration file, and not a per-user configuration file.

-Philip
