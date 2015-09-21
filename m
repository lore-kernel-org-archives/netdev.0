From: David Miller <davem@davemloft.net>
Subject: Re: [iproute2 net-next] ip route: Add RTM_F_LOOKUP_TABLE flag and
 show table id
Date: Mon, 21 Sep 2015 15:36:37 -0700 (PDT)
Message-ID: <20150921.153637.12993039889083787.davem@davemloft.net>
References: <56007E94.8000506@cumulusnetworks.com>
	<20150921.150346.926573540048522271.davem@davemloft.net>
	<56008351.7010005@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933047AbbIUWgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 18:36:40 -0400
In-Reply-To: <56008351.7010005@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 21 Sep 2015 16:23:13 -0600

> With the new flag a AND kernel that supports it ip will only show the
> table id IF it is not main:
> 
> root@vm-wheezy2:~# ./ip route get 10.0.0.20
> 10.0.0.20 dev eth0  src 10.0.0.2
>     cache
> 
> root@vm-wheezy2:~# ./ip route get 10.2.1.254
> 10.2.1.254 dev eth1  table 10  src 10.2.1.2
>     cache
> 
> That's my point. I have not changed existing users.

Ok, thanks for the clarification.  I misread the conditional
statements around the area your patch touches, sorry.
