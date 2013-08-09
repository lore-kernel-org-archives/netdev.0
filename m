From: Teco Boot <teco@inf-net.nl>
Subject: Re: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if subtree does not match
Date: Fri, 9 Aug 2013 16:12:20 +0200
Message-ID: <26D8997F-7CDF-425A-B0DC-4D57996871E5@inf-net.nl>
References: <20130807003431.GD16410@order.stressinduktion.org> <EF96A1CB-549E-474A-AF58-10F2D2F2BF4A@inf-net.nl> <20130807200637.GD32257@order.stressinduktion.org>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	equinox@diac24.net, boutier@pps.univ-paris-diderot.fr
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44160 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603Ab3HIOMZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 10:12:25 -0400
Received: by mail-ee0-f46.google.com with SMTP id c13so2142323eek.33
        for <netdev@vger.kernel.org>; Fri, 09 Aug 2013 07:12:23 -0700 (PDT)
In-Reply-To: <20130807200637.GD32257@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Double checked, it works. Tested with Common Open Research Emulator (CORE, from NRL).

=== But ===

I had some problems with CORE. Could be me, new kernel version, the patch, CORE using network namespaces, or combination of that. sudo hangs, reboot hangs, ip address show hangs.
With ps -ef, I see some suspected items:
root      4858  4161  0 15:57 ?        00:00:00 /sbin/ip -6 addr flush dev eth0
root      4859     2  0 15:57 ?        00:00:00 [kworker/0:3]
In the emulation I use, there was no IPv6.

I'll try to figure out if it is CORE & netns in combination with patch. Or just the patch. Or just the new kernel.
Just to speed up, any idea where to look for?

Thanks, Teco


Op 7 aug. 2013, om 22:06 heeft Hannes Frederic Sowa <hannes@stressinduktion.org> het volgende geschreven:

> On Wed, Aug 07, 2013 at 09:58:31PM +0200, Teco Boot wrote:
>> Seems to work!!
>> 
>> babe has one entry less than cafe, this is correct.
>> Tomorrow I'll test with real traffic.
> 
> Thanks for testing! I already used real traffic but it is better to
> double check.
> 
> Greetings,
> 
>  Hannes
> 
