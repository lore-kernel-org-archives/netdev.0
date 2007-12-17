From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2.6.25 0/9]: SCTP: Update ADD-IP implementation to conform to spec
Date: Mon, 17 Dec 2007 16:32:40 -0500
Message-ID: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:10967 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbXLQVcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 16:32:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following is a set of patches that updates the SCTP ADD-IP implementation
to conform to the recently published RFC.

ADD-IP is a SCTP Dynamic Address Configuration extensions, whereby
the two end systems can dynamically modify the address lists for a given
connection.  One of the applications of this is mobility.  The systems
exchange Address Configuration (ASCONF) and Address Configuration
Acknowlegement (ASCONF-ACK) messages which contain the info.  If you
want more info the operation, read RFC 5061.

The implementation in lksctp was a few years old and implemented draft-05
of the specification.  So this long overdue.

-vlad
