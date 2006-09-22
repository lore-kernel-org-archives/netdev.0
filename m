From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [Bugme-new] [Bug 7179] New: Compilation of .tmp_linux1
 fails due to missing declaration in net/netfilter/xt_physdev.c
Date: Fri, 22 Sep 2006 13:58:05 +0200
Message-ID: <4513CFCD.5090500@trash.net>
References: <20060921153701.2c49e331.akpm@osdl.org> <20060922084108.GB6820@ff.dom.local> <20060922092731.GC6820@ff.dom.local> <20060922095556.GA11991@ff.dom.local> <4513B7CF.5040209@trash.net> <20060922105122.GA12425@ff.dom.local> <4513C0F2.1030107@trash.net> <20060922114844.GB12425@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:22144 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932317AbWIVL6I
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 07:58:08 -0400
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20060922114844.GB12425@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> Anyway this special logic is also something misleading:
> 
> a) BRIDGE_NETFILTER=y and BRIDGE_NETFILTER depends on BRIDGE
> sugest something which depends on BRIDGE is compiled into
> kernel, which is usually impossible if BRIDGE=m
> 
> b) let's assume a) is right; shouldn't this dependency be
> automatically added to _PHYSDEV etc.? I mean config script
> behavior - not bridge makefile.

Frankly, I don't care. And I'm definitely not interested in hacking
Kconfig.

