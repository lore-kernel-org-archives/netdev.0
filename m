From: Patrick McHardy <kaber@trash.net>
Subject: Re: port bound SAs
Date: Tue, 27 Jan 2009 18:12:17 +0100
Message-ID: <497F4071.2040302@trash.net>
References: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com>	<BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com> <20090126.222035.100955508.davem@davemloft.net> <497EE171.1030907@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77515@exch-one.centrify.com> <497F3DD0.5010502@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77520@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Paul Moore <paul.moore@centrify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42408 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757281AbZA0RMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 12:12:19 -0500
In-Reply-To: <BB7E16A14DE689469A181EC770AFBF4D02A77520@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore wrote:
> i did exactly that (in the original message) and it makes this test case
> work but as I point out
> 
> a) it should not be necessary 
> b) i get more SAs than I need
> c) i can no longer say that a SA is optional (this is an error in the
> pfkey/xfrm/racoon interface to combine two orthogonal concepts)
> d) I am not convinced that I have resolved all cases. Needs more testing

IIRC I tested port selectors in SA a few years ago using "ip xfrm"
and they worked fine. The xfrm interface doesn't ignore them 
(copy_from_user_state()), I think the pfkey interface also doesn't.

Please try configuring them manually using "ip xfrm state",
I'm pretty sure the bug is actually in racoon.
