From: "Paul Moore" <paul.moore@centrify.com>
Subject: RE: port bound SAs
Date: Wed, 28 Jan 2009 10:07:11 -0800
Message-ID: <BB7E16A14DE689469A181EC770AFBF4D02A7774E@exch-one.centrify.com>
References: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com>	<BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com> <20090126.222035.100955508.davem@davemloft.net> <497EE171.1030907@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77515@exch-one.centrify.com> <497F3DD0.5010502@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77722@exch-one.centrify.com> <49809DD5.6080104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.centrify.com ([216.112.107.103]:40691 "EHLO
	exch-one.centrify.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751283AbZA1SHM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 13:07:12 -0500
Content-class: urn:content-classes:message
In-Reply-To: <49809DD5.6080104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So how do I get an SA with a port set on it


-----Original Message-----
From: Patrick McHardy [mailto:kaber@trash.net] 
Sent: Wednesday, January 28, 2009 10:03 AM
To: Paul Moore
Cc: David Miller; netdev@vger.kernel.org
Subject: Re: port bound SAs

Paul Moore wrote:
> So where did we get to on this?
> 
> My main question is - do you agree this is incorrect behavior of the
> overall system (racoon, pfkey, xfrm, ip) without trying to say which
bit
> is to blame?

No, so far everything seems fine. The SAs don't have a port selector,
no reqid is specified => Linux is allowed to reuse them.
