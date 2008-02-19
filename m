From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 0/5][SYSCTL]: Make some sysctl RO in net namespaces.
Date: Tue, 19 Feb 2008 14:54:55 +0300
Message-ID: <47BAC38F.10100@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56654 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750825AbYBSLzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 06:55:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David.

Some time ago, when I made the net.core.somaxconn ctl per-namespace,
you told that the approach I used to make some ctl tables read-only
in namespace was not very good and said to improve it. After looking
at other code, I decided, that many ctl variables will have to be 
read-only in namespace, so we need some generic way to do this.

So, here's the patchset, that allows to create ctl tables, that are
read-only in some namespace in general (and in some net namespace in 
particular). I tried to make it work the way not to consume extra
memory at run time.

This patchset is related to net namespaces only, but on the other hand
it affects the core sysctl engine. What is your opinion about this set:
should I send these patches (or some of them) to Andrew instead and wait 
till it appears in mainline (and sequentially in net tree) or will you
accept this one in net-2.6.26?

Thanks,
Pavel

