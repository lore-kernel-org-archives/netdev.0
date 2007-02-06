From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] Fw: Intermittent SCTP multihoming breakage
Date: Tue, 06 Feb 2007 16:48:42 -0500
Message-ID: <45C8F7BA.6010007@hp.com>
References: <E096369D937D3A4DB271B382850C5C5F48E60D@pysmail.eicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Sridhar Samudrala <sri@us.ibm.com>
To: Steve Hill <steve.hill@dialogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:50454 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965539AbXBFVsp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 16:48:45 -0500
In-Reply-To: <E096369D937D3A4DB271B382850C5C5F48E60D@pysmail.eicon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Hill wrote:
> Vlad Yasevich wrote on 05 February 2007 20:35:
> 
>> would you mind terribly, changing the -d "$net" to the
>> -i "$net", and run the script with the interface name instead?
> 
> I seem to get the same failure when dropping traffic based on interface
> as I do when dropping based on address.

Hmm... can you try with a more recent sender please.  Running 2.6.19 or
2.6.20 with my patch, I don't see this problem when a single interface fails.

I see a full path failover withing the 5 second timeout of the table rule.
Once failover happens, the traffic is using the second interface.

I haven't tried forcing the failover back to the first one, but I can
try flip-flopping them and see what happens.

> 
>> When I block at the ip address, I see the path failover
>> in an odd state.  It looks like it happened, but the flow is
>> not resumed.  Receive still doesn't get traffic. I think I might
> 
> This sounds like it might be the same problem I'm seeing.
> 
> My sender is running the 2.6.16.1 kernel with your patch applied, the
> receiver is running Fedora Core 6's 2.6.18-1.2798.fc6 kernel.  The
> iptables rules are being set on the receiver (so there should be no odd
> interactions between the sender's SCTP stack and iptables - as far as
> the sender knows the packets have been transmitted and lost in transit).

Yes, that's what I am doing as well.  I'll see if I can run a more recent
receiver.

Thanks
-vlad
