From: "Alexander V. Lukyanov" <lav@netis.ru>
Subject: Re: 2.6.29.1: unregister_netdevice problem
Date: Sun, 10 May 2009 11:35:59 +0400
Message-ID: <20090510073559.GA8929@night.netis.ru>
References: <20090422055735.GA4334@night.netis.ru> <20090427054103.GA27529@night.netis.ru> <20090428125755.GA5242@night.netis.ru> <49F76BF6.4040709@gmail.com> <20090429054510.GA8267@night.netis.ru> <20090429090809.GA2995@ami.dom.local> <20090508062640.GA4555@night.netis.ru> <20090508104628.GA6287@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from night.yars.free.net ([193.233.48.54]:57220 "EHLO
	night.yars.free.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbZEJHgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2009 03:36:15 -0400
Content-Disposition: inline
In-Reply-To: <20090508104628.GA6287@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 08, 2009 at 10:46:28AM +0000, Jarek Poplawski wrote:
> I can't see anything suspicious for now, except these UDP and TCP
> warnings. Did you see similar messages with 2.6.27? Btw., could this

Yes. Such messages show up with any kernel version.

> eth0.987 be "connected" with any of this traffic? (IP# ?)

No, eth0.987 is only used for traffic output.

BTW, it seems that only actively used vlan interfaces have the problem
(even when the traffic stops). Other vlan interfaces with little traffic
can be removed with no problems.

-- 
   Alexander..
