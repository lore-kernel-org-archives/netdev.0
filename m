From: Patrick McHardy <kaber@trash.net>
Subject: Re: ipv4 05/05: add sysctl to accept packets with local source addresses
Date: Fri, 04 Dec 2009 08:55:51 +0100
Message-ID: <4B18C087.8070804@trash.net>
References: <20091203112550.15100.86217.sendpatchset@x2.localnet>	<20091203112557.15100.85827.sendpatchset@x2.localnet> <m13a3rfa5j.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48076 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbZLDHzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 02:55:46 -0500
In-Reply-To: <m13a3rfa5j.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>> commit 8ec1e0ebe26087bfc5c0394ada5feb5758014fc8
>> Author: Patrick McHardy <kaber@trash.net>
>> Date:   Thu Dec 3 12:16:35 2009 +0100
>>
>>     ipv4: add sysctl to accept packets with local source addresses
>>     
>>     Change fib_validate_source() to accept packets with a local source address when
>>     the "accept_local" sysctl is set for the incoming inet device. Combined with the
>>     previous patches, this allows to communicate between multiple local interfaces
>>     over the wire.
>>     
>>     Signed-off-by: Patrick McHardy <kaber@trash.net>
>>
> 
> Obligatory grumble. New binary sysctl.  Grumble.
> 
> Honestly this might be the one new sysctl that doesn't conflict with
> my sysctl tree.  That should merge to Linus sometime this merge cycle
> which will stop exporting this to userspace. So I don't have any
> real complaints.  Grumble.
> 
> This overloading of sysctl.h for the binary sysctl numbers and
> the index into the perdevice sysctls is something we should probably
> change at some point to keep maintenance a little less confusing.

Yes, unfortunately its currently not possible to add inetdev sysctls
without allocating new numbers.
