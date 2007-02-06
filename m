From: "Steve Hill" <steve.hill@dialogic.com>
Subject: RE: [Lksctp-developers] Fw: Intermittent SCTP multihoming breakage
Date: Tue, 6 Feb 2007 04:26:30 -0500
Message-ID: <E096369D937D3A4DB271B382850C5C5F48E60D@pysmail.eicon.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	<lksctp-developers@lists.sourceforge.net>,
	"Sridhar Samudrala" <sri@us.ibm.com>
To: "Vlad Yasevich" <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eiconlon.eicon.com ([82.108.230.130]:11803 "EHLO
	EiconLON.eicon.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751897AbXBFJkK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 04:40:10 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich wrote on 05 February 2007 20:35:

> would you mind terribly, changing the -d "$net" to the
> -i "$net", and run the script with the interface name instead?

I seem to get the same failure when dropping traffic based on interface
as I do when dropping based on address.

> When I block at the ip address, I see the path failover
> in an odd state.  It looks like it happened, but the flow is
> not resumed.  Receive still doesn't get traffic. I think I might

This sounds like it might be the same problem I'm seeing.

My sender is running the 2.6.16.1 kernel with your patch applied, the
receiver is running Fedora Core 6's 2.6.18-1.2798.fc6 kernel.  The
iptables rules are being set on the receiver (so there should be no odd
interactions between the sender's SCTP stack and iptables - as far as
the sender knows the packets have been transmitted and lost in transit).

Thanks.

 - Steve Hill
   Software Engineer
   Dialogic
   Fordingbridge, Hampshire, UK
   +44-1425-651392
   steve.hill@dialogic.com
