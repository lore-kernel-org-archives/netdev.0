From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH] Fix: kmemleak in tcp_v4/6_syn_recv_sock and dccp_v4/6_request_recv_sock
Date: Fri, 14 Dec 2012 08:59:38 +0100
Message-ID: <15583655.5x5gqCFMiY@cpaasch-mac>
References: <1355435363-12766-1-git-send-email-christoph.paasch@uclouvain.be> <1355441890.10504.4.camel@edumazet-glaptop>
Reply-To: Christoph Paasch <christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:40845 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810Ab2LNH7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 02:59:46 -0500
In-Reply-To: <1355441890.10504.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thursday 13 December 2012 15:38:10 Eric Dumazet wrote:
> Are you sure the above commit is the bug origin ?
> 
> It looks like bug was bring by transparent proxy in 2.6.37
> 
> commit 093d282321daeb19c107e5f1f16d7f68484f3ade
> Author: Balazs Scheidler <bazsi@balabit.hu>
> Date:   Thu Oct 21 13:06:43 2010 +0200

yes, you are right.

My patch would not easily apply on kernels < 3.0, as it depends on the 
"put_and_exit"-goto.
Should I send a separate patch? And to whom? (I don't find any guidelines 
about how to submit patches to older stable kernels)


Thanks,
Christoph

-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
UCLouvain
--
