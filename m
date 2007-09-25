From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently
	runsoftirqnetwork code on SMP
Date: Tue, 25 Sep 2007 18:22:24 -0400
Message-ID: <1190758944.4244.23.camel@localhost>
References: <004901c7fd9c$94370df0$d6ddfea9@JOHNYE1>
	 <1190551422.4256.36.camel@localhost>
	 <007201c7ff89$d5db4cf0$d6ddfea9@JOHNYE1>
	 <20070925090333.11beebb2@freepuppy.rosehill>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: john ye <johny@asimco.com.cn>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de, iceburgue@gmail.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:16869 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbXIYWW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 18:22:28 -0400
Received: by an-out-0708.google.com with SMTP id d31so311356and
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2007 15:22:27 -0700 (PDT)
In-Reply-To: <20070925090333.11beebb2@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-25-09 at 09:03 -0700, Stephen Hemminger wrote:

> There is a standard hash called RSS, that many drivers support because it is
> used by other operating systems. 

I think any stateless/simple thing will do (something along the lines
what 802.1ad does for trunk, a 5 classical five tuple etc).

Having solved the reordering problem in such a stateless way introduces
a loadbalancing setback; you may end sending all your packets to one cpu
(a problem Mr Ye didnt have when he was re-orderding ;->).

cheers,
jamal

