From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Fri, 01 Dec 2006 15:18:21 -0800 (PST)
Message-ID: <20061201.151821.52117682.davem@davemloft.net>
References: <20061130102205.GA20654@2ka.mipt.ru>
	<20061130.121443.116355312.davem@davemloft.net>
	<20061201095306.GA21232@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nickpiggin@yahoo.com.au, mingo@elte.hu, wenji@fnal.gov,
	akpm@osdl.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:29826
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1162210AbWLAXSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 18:18:14 -0500
To: johnpol@2ka.mipt.ru
In-Reply-To: <20061201095306.GA21232@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 1 Dec 2006 12:53:07 +0300

> Isn't it a step in direction of full tcp processing bound to process
> context? :)

:-)

Rather, it is just finer grained locking.
