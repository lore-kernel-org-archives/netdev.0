From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Add missing skb->dev assignment in Frame Relay RX code
Date: Mon, 30 Jun 2008 20:12:39 +0200
Message-ID: <m3fxqu6bc8.fsf@maximus.localdomain>
References: <m3wsk8aupw.fsf@maximus.localdomain>
	<20080629130420.62d00d59@extreme> <m3od5kaqx8.fsf@maximus.localdomain>
	<20080630101948.535496a9@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:32994 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756110AbYF3SMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2008 14:12:41 -0400
In-Reply-To: <20080630101948.535496a9@extreme> (Stephen Hemminger's message of "Mon\, 30 Jun 2008 10\:19\:48 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> netdev_alloc_skb does two things:
>   1) it sets skb->dev
>   2) on some platforms it can choose memory "closer" to the device.
>      but this is really a NUMA issue

I see. It looks like I should use it for sending control messages
then. Thanks.
-- 
Krzysztof Halasa
