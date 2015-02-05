From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: Let bridge not age 'externally'
 learnt FDB entries, they are removed when 'external' entity notifies the
 aging
Date: Wed, 04 Feb 2015 23:53:08 -0800 (PST)
Message-ID: <20150204.235308.71797582017426266.davem@davemloft.net>
References: <CA+CtxLSziWmx94_V9S-uW9=6VYg4WXsU4CERx-uovvrFOtO1dA@mail.gmail.com>
	<54D246A7.2020502@cumulusnetworks.com>
	<CAE4R7bCASKHmZD+tiu=ZWM9dzvTrSLsaXxgtOYLpsmOR87kcTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, siva.mannem.lnx@gmail.com,
	netdev@vger.kernel.org, sfeldma@cumulusnetworks.com,
	jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41963 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbbBEHxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 02:53:10 -0500
In-Reply-To: <CAE4R7bCASKHmZD+tiu=ZWM9dzvTrSLsaXxgtOYLpsmOR87kcTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Wed, 4 Feb 2015 23:13:07 -0800

> I'd like to see this patch reverted so we can have a more
> comprehensive discussion/solution.  With this patch applied, the only
> user (rocker) of NETDEV_SWITCH_FDB_ADD is broken.  So please undo this
> patch so rocker isn't broken and let's work on a knob to suit both
> modes: 1) let bridge manage aging, 2) let device manage aging.

Patch reverted.
