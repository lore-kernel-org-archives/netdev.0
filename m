From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH iproute2 3/2] tc_core: Return double from	tc_core_tick2time()
Date: Wed, 10 Jun 2009 01:04:36 +0200
Message-ID: <4A2EEA84.3080803@trash.net>
References: <20090609080536.GD5237@ff.dom.local> <4A2E6BA4.30002@trash.net> <20090609225317.GA3262@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Antonio Almeida <vexwek@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <devik@cdi.cz>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41547 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbZFIXEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 19:04:36 -0400
In-Reply-To: <20090609225317.GA3262@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Hmm... I'm not sure this floor() is needed here, but maybe I'll get it
> tomorrow... 

Its not. It was mainly a suggestion to make the symetry more explicit.
I hope gcc understands :)
