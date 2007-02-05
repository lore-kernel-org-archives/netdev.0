From: "Steve Hill" <steve.hill@dialogic.com>
Subject: RE: [Lksctp-developers] Fw: Intermittent SCTP multihoming breakage
Date: Mon, 5 Feb 2007 09:13:09 -0500
Message-ID: <E096369D937D3A4DB271B382850C5C5F44E22D@pysmail.eicon.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Sridhar Samudrala" <sri@us.ibm.com>, <netdev@vger.kernel.org>,
	<lksctp-developers@lists.sourceforge.net>
To: "Vlad Yasevich" <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from montreal.eicon.com ([192.219.17.124]:20990 "EHLO
	EICONMTL.eicon.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S932735AbXBEOMd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 09:12:33 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich wrote on 25 January 2007 16:33:

> Can you try the attached patch and let me know if the problem is
> fixed.  You can try reducing rto_max or path_max_retrans to get the
> failover to happen a little faster. 

Sorry for the delay - I've been on vacation for the past week.

I've tried applying the patch.  However, the failure still seems to
happen in the original test system with a patched kernel.  A look at the
network traffic shows that the receiving side is still returning a
gap-ack, the chunks in the gap are never resent and I don't see a
FORWARD TSN for them.

 - Steve Hill
   Software Engineer
   Dialogic
   Fordingbridge, Hampshire, UK
   +44-1425-651392
   steve.hill@dialogic.com
