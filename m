From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for December 15 (netlabel)
Date: Mon, 15 Dec 2008 11:22:04 -0800
Message-ID: <4946AE5C.9040207@oracle.com>
References: <20081216020642.fc1007d9.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	paul.moore@hp.com, netdev <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:57253 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbYLOTWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 14:22:07 -0500
In-Reply-To: <20081216020642.fc1007d9.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netlabel_domainhash fails to build when IPV6 is not enabled:

build-r7133.out:/local/linsrc/linux-next-20081215/net/netlabel/netlabel_domainhash.c:527: error: implicit declaration of function 'netlbl_af6list_foreach_rcu'
build-r7133.out:/local/linsrc/linux-next-20081215/net/netlabel/netlabel_domainhash.c:528: error: expected ';' before 'goto'
build-r7133.out:make[3]: *** [net/netlabel/netlabel_domainhash.o] Error 1


~Randy

