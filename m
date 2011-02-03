From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Thu, 03 Feb 2011 15:00:28 +0100
Message-ID: <47859e9273bb0c1b2c32fc1adfa450ee@localhost>
References: <20110202.170750.229739784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <dccp@vger.kernel.org>,
	<therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:56605 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756363Ab1BCOAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 09:00:30 -0500
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 02 Feb 2011 17:07:50 -0800 (PST), David Miller wrote:



> +/* TCP initial congestion window */

> +#define TCP_INIT_CWND		10

> +



Davem, there is _no_ research how this huge IW will behave in environments

with a small BDP. Belief it or not, but there are networks out there with a

BDP similar to ~1980. Why for heaven's sake should this work in these

environments? There are only _two_ extensive analysis one from Cherry and

and one from Ilpo. Both analysis focus on current mainstream BDP. I started

to setup a ns-2 environment but due to lack of time I am a little bit

behind schedule. Anyway, why not make this a tunable per route knob so that

it is easier to fix things, e.g. set IW back to 3.



HGN
