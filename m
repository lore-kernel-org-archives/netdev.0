From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Check if user has CAP_NET_ADMIN to change congestion
 control algorithm
Date: Thu, 26 Oct 2006 17:07:32 -0700 (PDT)
Message-ID: <20061026.170732.26277153.davem@davemloft.net>
References: <20061026224407.GA2018@c3po.0xdef.net>
	<20061026235256.GB2018@c3po.0xdef.net>
	<5640c7e00610261659g5816942ndaf4e09eb8110c9e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, jheffner@psc.edu, shemminger@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62088
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946041AbWJ0AHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 20:07:51 -0400
To: ian.mcdonald@jandi.co.nz
In-Reply-To: <5640c7e00610261659g5816942ndaf4e09eb8110c9e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 27 Oct 2006 12:59:30 +1300

> I don't agree with this at all. I would love Firefox, BitTorrent etc
> to implement usage of TCP-LP for example so they use "unused"
> bandwidth only.
> 
> With this change applications can't do this.
> 
> If we are going to restrict by capabilities then I think we should
> only restrict module loading - this way the admin of the box can
> decide what algorithms can be used.

You are using an example of a (supposedly) safe case of this
as a justification for allowing all cases.

It is bad, very bad, to allow arbitrary users to select arbitrary
congestion control algorithms.  It is just as bad as allowing them to
disable congestion control completely if that were an option.

If someone, for example, builds all the algorithms statically into
their kernel, for testing as root, this lets all users on the machine
do the same which is not right.

