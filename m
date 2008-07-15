From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC 01/10] mlx4_en: Include file
Date: Tue, 15 Jul 2008 12:29:01 -0700
Message-ID: <adafxqbdk02.fsf@cisco.com>
References: <487B6569.5000806@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:18905 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbYGOTdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 15:33:44 -0400
In-Reply-To: <487B6569.5000806@mellanox.co.il> (Yevgeny Petrilin's message of
	"Mon, 14 Jul 2008 17:40:41 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +enum mlx4_en_state {
 > +	DEVICE_DOWN,
 > +	DEVICE_UP,
 > +	DEVICE_GOING_DOWN,
 > +	DEVICE_DISABLED
 > +};

I don't see any place that sets the state to anything other than UP or
DOWN.  Maybe it would be clearer to get rid of the enum and just have

	bool      device_up;

in your structure?
