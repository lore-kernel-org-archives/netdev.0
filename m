From: "Paul Moore" <paul.moore@centrify.com>
Subject: RE: port bound SAs
Date: Tue, 27 Jan 2009 09:24:19 -0800
Message-ID: <BB7E16A14DE689469A181EC770AFBF4D02A77527@exch-one.centrify.com>
References: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com>	<BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com> <20090126.222035.100955508.davem@davemloft.net> <497EE171.1030907@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77515@exch-one.centrify.com> <497F3DD0.5010502@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77520@exch-one.centrify.com> <497F4071.2040302@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77522@exch-one.centrify.com> <497F429C.6010006@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.centrify.com ([216.112.107.103]:47162 "EHLO
	exch-one.centrify.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753370AbZA0RYV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 12:24:21 -0500
Content-class: urn:content-classes:message
In-Reply-To: <497F429C.6010006@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>I believe thats intentional, RFC2367 specifies to ignore port
numbers except for larval states.

the ietf ipsec list thinks thats not the case. The consensus there is
that the port owns the SA (and thats what Windows, and solaris actually
do)

-----Original Message-----
From: Patrick McHardy [mailto:kaber@trash.net] 
Sent: Tuesday, January 27, 2009 9:22 AM
To: Paul Moore
Cc: David Miller; netdev@vger.kernel.org
Subject: Re: port bound SAs

Paul Moore wrote:
> the pfkey / xfrm interface throws them away

I misparsed that statement, I thought you meant both. Yes, you
seem to be right, pfkey ignores them.

> i fixed racoon to send the port numbers and they were ignored

I believe thats intentional, RFC2367 specifies to ignore port
numbers except for larval states.
