From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 00/10] netdev: get rid of read_lock(&dev_base_lock)
 usages
Date: Tue, 10 Nov 2009 10:24:42 -0800
Message-ID: <20091110102442.733c22bc@nehalam>
References: <20091110175446.280423729@vyatta.com>
	<4AF9AE66.3010303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52576 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041AbZKJSY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 13:24:58 -0500
In-Reply-To: <4AF9AE66.3010303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was just trying to pick up the stragglers you left behind :-)

The nasty cases left are bonding (whose existing locking model is a pile
of crap), and sysfs (slightly less stinky). The bonding code just needs to
be rewritten to have a sane/simple model. 

