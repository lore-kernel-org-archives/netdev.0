From: "Paul Moore" <paul.moore@centrify.com>
Subject: RE: reading SA state via XFRM / AF_NETLINK
Date: Fri, 10 Apr 2009 09:25:50 -0700
Message-ID: <BB7E16A14DE689469A181EC770AFBF4D02EF3D74@exch-one.centrify.com>
References: <BB7E16A14DE689469A181EC770AFBF4D02EF39B6@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Paul Moore" <paul.moore@centrify.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.centrify.com ([216.112.107.103]:30351 "EHLO
	exch-one.centrify.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751309AbZDJQZz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 12:25:55 -0400
Content-class: urn:content-classes:message
In-Reply-To: <BB7E16A14DE689469A181EC770AFBF4D02EF39B6@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I will take the thunderous silence as a confirmation that this data is
not available via xfrm
any suggestions on how to synthesize it would be welcome

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Paul Moore
Sent: Tuesday, April 07, 2009 6:21 PM
To: netdev@vger.kernel.org
Subject: reading SA state via XFRM / AF_NETLINK

as far as I can see there is no way to read the state (larval, mature,
dying, etc) of an SA via AF_NETLINK

af_key.c provides this information to AF_KEY callers by peeking at
xfrm_state.km.state but xfrm_user.c does not seem to make this data
available (and there dont appear to be places in the user mode xfrm
structures for it either)

is this correct? did I miss a back channel somewhere?
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
