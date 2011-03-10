From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Wed, 9 Mar 2011 22:17:04 -0800 (PST)
Message-ID: <2049243270.17294.1299737824096.JavaMail.root@tahiti.vyatta.com>
References: <20110310002458.5a94f563.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Injong Rhee <rhee@ncsu.edu>, David Miller <davem@davemloft.net>,
	xiyou wangcong <xiyou.wangcong@gmail.com>,
	netdev@vger.kernel.org, sangtae ha <sangtae.ha@gmail.com>,
	Lucas Nussbaum <lucas.nussbaum@loria.fr>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51191 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832Ab1CJGRG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 01:17:06 -0500
In-Reply-To: <20110310002458.5a94f563.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill what is the HZ in your kernel config.
I am concerned hystart doesn't work well with HZ=100
