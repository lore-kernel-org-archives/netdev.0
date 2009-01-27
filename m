From: "Paul Moore" <paul.moore@centrify.com>
Subject: RE: port bound SAs
Date: Tue, 27 Jan 2009 09:05:08 -0800
Message-ID: <BB7E16A14DE689469A181EC770AFBF4D02A77520@exch-one.centrify.com>
References: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com>	<BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com> <20090126.222035.100955508.davem@davemloft.net> <497EE171.1030907@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77515@exch-one.centrify.com> <497F3DD0.5010502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.centrify.com ([216.112.107.103]:45482 "EHLO
	exch-one.centrify.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753934AbZA0RFN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 12:05:13 -0500
Content-class: urn:content-classes:message
In-Reply-To: <497F3DD0.5010502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i did exactly that (in the original message) and it makes this test case
work but as I point out

a) it should not be necessary 
b) i get more SAs than I need
c) i can no longer say that a SA is optional (this is an error in the
pfkey/xfrm/racoon interface to combine two orthogonal concepts)
d) I am not convinced that I have resolved all cases. Needs more testing

-----Original Message-----
From: Patrick McHardy [mailto:kaber@trash.net] 
Sent: Tuesday, January 27, 2009 9:01 AM
To: Paul Moore
Cc: David Miller; netdev@vger.kernel.org
Subject: Re: port bound SAs

Paul Moore wrote:
> racoon
> 
> if I look at the xfrm/pfkey code in the kernel it ignores any ports
sent
> down by the IKE daemon in transport mode. I actually changed the
racoon
> code to include the ports and it makes no difference

Assuming you're also using setkey, try adding "unique" to your policies.

