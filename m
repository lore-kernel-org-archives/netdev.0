From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Fw: [Bug 39132] Starting with 3.0.0-rc6, masquerading seems to
 be broken.
Date: Thu, 4 Aug 2011 21:38:48 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108042131040.1495@ja.ssi.bg>
References: <20110804193107.68d93727@schatten.dmk.lab>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hilld@binarystorm.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Florian Mickler <florian@mickler.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58364 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752640Ab1HDSe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 14:34:28 -0400
In-Reply-To: <20110804193107.68d93727@schatten.dmk.lab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 4 Aug 2011, Florian Mickler wrote:

> Can someone take a look at this regression?
> 
> Begin forwarded message:
> 
> Date: Thu, 28 Jul 2011 04:51:12 GMT
> From: bugzilla-daemon@bugzilla.kernel.org
> To: florian@mickler.org
> Subject: [Bug 39132] Starting with 3.0.0-rc6, masquerading seems to be
> broken.
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=39132

	So, problem points again to
"Fix ip_route_me_harder triggering ip_rt_bug" ? May be
David C. Hill or Florian can provide some information, eg. is
tproxy used, what NAT rules are used, any rules in OUTPUT
hooks (NAT/mangle) and which packets are dropped.

Regards

--
Julian Anastasov <ja@ssi.bg>
