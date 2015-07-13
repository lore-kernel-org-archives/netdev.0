From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sctp: SCTP_SOCKOPT_PEELOFF return socket pointer
 for kernel users
Date: Mon, 13 Jul 2015 11:59:12 -0700 (PDT)
Message-ID: <20150713.115912.324798425601463403.davem@davemloft.net>
References: <4dfd0ee7ac0aac0791812217e990e2ae7ff86955.1434645734.git.marcelo.leitner@gmail.com>
	<20150710.182114.1532697560595947999.davem@davemloft.net>
	<20150713103911.GA9631@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcelo.leitner@gmail.com, netdev@vger.kernel.org,
	vyasevich@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43166 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947AbbGMS7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 14:59:15 -0400
In-Reply-To: <20150713103911.GA9631@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 13 Jul 2015 06:39:11 -0400

> Initially Marcelo had created duplicate code paths, one to return an
> fd, one to return a file struct.  If you would rather go in that
> direction, I'm sure he can propose it again, but that seems less
> correct to me than this solution.

That's much better.
