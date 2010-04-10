From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: net-next: 2.6.34-rc1 regression: panic when running diagnostic
 on interface with IPv6
Date: Fri, 9 Apr 2010 19:21:13 -0700 (PDT)
Message-ID: <8144239.79851270866073075.JavaMail.root@tahiti.vyatta.com>
References: <EA929A9653AAE14F841771FB1DE5A1365FE4FCD423@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Emil S Tantilov <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33648 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753243Ab0DJCVh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Apr 2010 22:21:37 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FE4FCD423@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> I played with it some more to get the exact commands. Looks like the
> following should repro it:
> 
> ifconfig eth0 inet6 add fec0::1509/112 up
> ethtool -t eth0
> ifconfig eth0 inet6 del fec0::1509/112

Yes, that causes WARN() to trigger, but only if there is a delay
between ethtool (down/up transition) and the address delete.

