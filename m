From: Patrick McHardy <kaber@trash.net>
Subject: Re: port bound SAs
Date: Tue, 27 Jan 2009 18:42:22 +0100
Message-ID: <497F477E.6020209@trash.net>
References: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com>	<BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com> <20090126.222035.100955508.davem@davemloft.net> <497EE171.1030907@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77515@exch-one.centrify.com> <497F3DD0.5010502@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77520@exch-one.centrify.com> <497F4071.2040302@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77522@exch-one.centrify.com> <497F429C.6010006@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77527@exch-one.centrify.com> <497F4460.4080901@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77531@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Paul Moore <paul.moore@centrify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43007 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370AbZA0Rm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 12:42:26 -0500
In-Reply-To: <BB7E16A14DE689469A181EC770AFBF4D02A77531@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore wrote:
> OK I misunderstood. Sorry
>
> You are saying that the port number should be dropped by the pfkey /
> xfrm interface - OK
>   

Yes. I think thats also why it includes the unique" option.

> This is actually what happens. (BTW this is fortunate - in a few cases
> racoon accidentally passes down 500)
>
> I meant that the consensus was that the wire behavior is wrong. 

Yes, if the selectors would actually differ, it would be wrong.
