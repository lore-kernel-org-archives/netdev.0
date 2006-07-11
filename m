From: Andy Gay <andy@andynet.net>
Subject: IPsec and netfilter needs INPUT rule for protocol 4?
Date: Tue, 11 Jul 2006 09:54:42 -0400
Message-ID: <1152626083.20072.252.camel@tahini.andynet.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms044pub.verizon.net ([206.46.252.44]:41166 "EHLO
	vms044pub.verizon.net") by vger.kernel.org with ESMTP
	id S1750795AbWGKNyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 09:54:47 -0400
Received: from andyhp.tranquilitynj.net ([138.89.61.131])
 by vms044.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
 with ESMTPA id <0J2800942RZ9UPY4@vms044.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 11 Jul 2006 08:54:45 -0500 (CDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since 2.6.16 it's been necessary to add an ACCEPT rule for IPIP
(protocol 4) in the INPUT chain, otherwise IPsec tunnel mode packets get
dropped (if your INPUT policy is DROP).

I was wondering if that's the intended behavior. I did google around for
this, I found a few reports of the same thing but no explanation. For
example, Patrick discusses this in -
http://lists.netfilter.org/pipermail/netfilter-devel/2006-February/023420.html
but that thread seems to end inconclusively.


