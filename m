From: "Paul Moore" <paul.moore@centrify.com>
Subject: reading SA state via XFRM / AF_NETLINK
Date: Tue, 7 Apr 2009 18:20:48 -0700
Message-ID: <BB7E16A14DE689469A181EC770AFBF4D02EF39B6@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.centrify.com ([216.112.107.103]:26008 "EHLO
	exch-one.centrify.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756862AbZDHBUu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 21:20:50 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

as far as I can see there is no way to read the state (larval, mature,
dying, etc) of an SA via AF_NETLINK

af_key.c provides this information to AF_KEY callers by peeking at
xfrm_state.km.state but xfrm_user.c does not seem to make this data
available (and there dont appear to be places in the user mode xfrm
structures for it either)

is this correct? did I miss a back channel somewhere?
