From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Fix: kmemleak in tcp_v4/6_syn_recv_sock and
 dccp_v4/6_request_recv_sock
Date: Fri, 14 Dec 2012 05:26:05 -0800
Message-ID: <1355491565.10504.7.camel@edumazet-glaptop>
References: <1355435363-12766-1-git-send-email-christoph.paasch@uclouvain.be>
	 <1355441890.10504.4.camel@edumazet-glaptop>
	 <15583655.5x5gqCFMiY@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:54918 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab2LNN0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 08:26:07 -0500
In-Reply-To: <15583655.5x5gqCFMiY@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-14 at 08:59 +0100, Christoph Paasch wrote:
> Hi Eric,
> 
> On Thursday 13 December 2012 15:38:10 Eric Dumazet wrote:
> > Are you sure the above commit is the bug origin ?
> > 
> > It looks like bug was bring by transparent proxy in 2.6.37
> > 
> > commit 093d282321daeb19c107e5f1f16d7f68484f3ade
> > Author: Balazs Scheidler <bazsi@balabit.hu>
> > Date:   Thu Oct 21 13:06:43 2010 +0200
> 
> yes, you are right.
> 
> My patch would not easily apply on kernels < 3.0, as it depends on the 
> "put_and_exit"-goto.
> Should I send a separate patch? And to whom? (I don't find any guidelines 
> about how to submit patches to older stable kernels)
> 

Please correct the changelog to include the right commit, so that we can
backport it to needed kernels later. This backport could be done by you
or someone else, don't worry. First step is to get the first patch in
current Linus tree, but with exact information in changelog.

Thanks
