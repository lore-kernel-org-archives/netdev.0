From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Fri, 09 May 2008 14:32:29 -0700 (PDT)
Message-ID: <20080509.143229.174354251.davem@davemloft.net>
References: <86802c440805071130m62c1f4edydb3316dac4a2aba2@mail.gmail.com>
	<20080507.141521.193714938.davem@davemloft.net>
	<482498D5.9060008@krogh.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jesper@krogh.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37763
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754545AbYEIVcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 17:32:35 -0400
In-Reply-To: <482498D5.9060008@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Krogh <jesper@krogh.cc>
Date: Fri, 09 May 2008 20:32:53 +0200

> When it works I doesnt seem to be able to get it pass 500MB/s.

With this card you really need multiple cpus and multiple threads
sending data through the card in order to fill the 10Gb pipe.

Single connections will not fill the pipe.
