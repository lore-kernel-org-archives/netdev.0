From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: RE: [PATCH 3/14] nes: connection manager routines
Date: Wed, 8 Aug 2007 10:31:17 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC07443E9D@venom2>
References: <200708080050.l780oGxo004694@neteffect.com> <p73d4xyryg2.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <rdreier@cisco.com>, <ewg@lists.openfabrics.org>,
	<netdev@vger.kernel.org>
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.neteffect.com ([204.57.75.68]:23902 "EHLO
	mail2.neteffect.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753655AbXHHPbS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 11:31:18 -0400
Content-class: urn:content-classes:message
In-Reply-To: <p73d4xyryg2.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This code is far from a TCP stack.  It's main purpose is to exchange
RDMA MPA request/response messages that are required by the iWarp specs
and therefore needed by our hardware.  All RNIC hardware vendors need
this MPA message exchange, including those already accepted into
kernel.org.  Do you have an alternative suggestion?

Thanks,
Glenn.

-----Original Message-----
From: ak@suse.de [mailto:ak@suse.de] On Behalf Of Andi Kleen
Sent: Wednesday, August 08, 2007 7:41 AM
To: Glenn Grundstrom
Cc: rdreier@cisco.com; ewg@lists.openfabrics.org; netdev@vger.kernel.org
Subject: Re: [PATCH 3/14] nes: connection manager routines

ggrundstrom@neteffect.com writes:

> NetEffect connection manager routines.

This seems more like a new TCP stack. I don't think such code is
appropiate, since Linux already has one.

-Andi
