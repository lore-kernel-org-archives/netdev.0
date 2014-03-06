From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add generic header
 handling routines
Date: Wed, 05 Mar 2014 19:39:13 -0500 (EST)
Message-ID: <20140305.193913.470467212827707623.davem@redhat.com>
References: <1393943688-24221-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<20140304.170050.2058599034902221847.davem@davemloft.net>
	<7c9810ea21990e7e239b101f548818f7.squirrel@webmail.itwm.fhg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13593 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756397AbaCFAjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 19:39:25 -0500
In-Reply-To: <7c9810ea21990e7e239b101f548818f7.squirrel@webmail.itwm.fhg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
Date: Wed, 5 Mar 2014 20:15:56 +0100

> The fc field in struct ieee802154_hdr is a bitfield with many subfields,
> the sc field of struct ieee802154_sec_hdr is also a bitfield. Would it be
> acceptable to represent them as bitfields in the header struct? I expect
> the code to be just as efficient in every respect, but more readable since
> we wouldn't need explicit shifts and masks everywhere.

This is how we handle some fields of struct iphdr, and it's fine with
me.

Be sure to use __LITTLE_ENDIAN_BITFIELD and __BIG_ENDIAN_BITFIELD for
your CPP checks.
