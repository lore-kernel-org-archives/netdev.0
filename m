From: Patrick McHardy <kaber@trash.net>
Subject: Re: port bound SAs
Date: Tue, 27 Jan 2009 18:29:04 +0100
Message-ID: <497F4460.4080901@trash.net>
References: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com>	<BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com> <20090126.222035.100955508.davem@davemloft.net> <497EE171.1030907@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77515@exch-one.centrify.com> <497F3DD0.5010502@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77520@exch-one.centrify.com> <497F4071.2040302@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77522@exch-one.centrify.com> <497F429C.6010006@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77527@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Paul Moore <paul.moore@centrify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42774 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786AbZA0R3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 12:29:06 -0500
In-Reply-To: <BB7E16A14DE689469A181EC770AFBF4D02A77527@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore wrote:
>>> I believe thats intentional, RFC2367 specifies to ignore port
> numbers except for larval states.
> 
> the ietf ipsec list thinks thats not the case. The consensus there is
> that the port owns the SA (and thats what Windows, and solaris actually
> do)

What does "think thats not the case" mean? Its clearly stated in
2.3.3. Address Extension:

...
    The
    zeroing of ports (e.g. sin_port and sin6_port) MUST be done for all
    messages except for originating SADB_ACQUIRE messages, which SHOULD
    fill them in with ports from the relevant TCP or UDP session which
    generates the ACQUIRE message.


