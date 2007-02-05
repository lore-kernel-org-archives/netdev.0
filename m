From: "Steve Hill" <steve.hill@dialogic.com>
Subject: RE: [Lksctp-developers] Fw: Intermittent SCTP multihoming breakage
Date: Mon, 5 Feb 2007 11:53:42 -0500
Message-ID: <E096369D937D3A4DB271B382850C5C5F44E657@pysmail.eicon.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	<lksctp-developers@lists.sourceforge.net>,
	"Sridhar Samudrala" <sri@us.ibm.com>
To: "Vlad Yasevich" <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from montreal.eicon.com ([192.219.17.124]:35165 "EHLO
	EICONMTL.eicon.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751743AbXBEQw6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 11:52:58 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich wrote on 05 February 2007 16:39:

> Once you start simulating the network failure, how long do you wait?
> 
> If you have not changed rto_max and path_max_retrans, you can end up
> waiting quite a while for the full path switchover.  This will also
> severely slow down your retransmissions...

I'm waiting several minutes, and I'm using setsockopt() to set the
timeouts fairly low:
	srto_initial = 1000ms
	srto_min = 200ms
	srto_max = 1400ms
	spp_pathmaxrxt = 2
	spp_hbinterval = 1000ms

The network's round trip time (indicated by ping) is on the order of
<0.25ms.

 - Steve Hill
   Software Engineer
   Dialogic
   Fordingbridge, Hampshire, UK
   +44-1425-651392
   steve.hill@dialogic.com
