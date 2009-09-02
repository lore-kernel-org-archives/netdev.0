From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH net-next-2.6] ip: Report qdisc packet drops
Date: Wed, 2 Sep 2009 13:22:25 -0500 (CDT)
Message-ID: <alpine.DEB.1.10.0909021318490.21832@V090114053VZO-1>
References: <4A98132C.8090105@gmail.com> <20090828.233858.256193304.davem@davemloft.net> <4A9BBD8E.2010303@gmail.com> <20090901.184121.06750444.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, sri@us.ibm.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com,
	mtk.manpages@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:51131 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751716AbZIBOXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 10:23:32 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 02B8A82C76D
	for <netdev@vger.kernel.org>; Wed,  2 Sep 2009 10:25:16 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id s+tLHDbUfNTg for <netdev@vger.kernel.org>;
	Wed,  2 Sep 2009 10:25:15 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9948382C74E
	for <netdev@vger.kernel.org>; Wed,  2 Sep 2009 10:25:03 -0400 (EDT)
In-Reply-To: <20090901.184121.06750444.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Sep 2009, David Miller wrote:

> > 2) Submit a patch to account for qdisc-dropped frames in SNMP counters
> > but still return a OK to user application, to not break them ?
>
> Sounds good.

Great. That was my initial suggestion and it would ensure that no apps
break.

> If we are to make such applications "more sophisticated" such
> converted apps can be indicated simply their use of IP_RECVERR.

There may be a minor issue here in that IP_RECVERR sometimes sends error
packets that have to be intercepted using special code. Or can those be
simply ignored? If so then I will ask UDP app vendors to use IP_RECVERR.

> As usual, Alexey Kuznetsov's analysis of this situation is timeless,
> accurate, and wise.  And he understood all of this 10+ years ago.

His code was just slightly buggy .... ;-)
