From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Sun, 02 Jun 2013 16:31:35 -0700
Message-ID: <1370215895.24311.93.camel@edumazet-glaptop>
References: <519CB2D8.103@yandex-team.ru>
	   <1369225837.3301.324.camel@edumazet-glaptop>
	   <519CC2FB.2010006@yandex-team.ru>
	   <20130522174532.GC3431@linux.vnet.ibm.com>
	 <519D19DA.50400@yandex-team.ru>
	   <20130525113715.GA3795@linux.vnet.ibm.com>
	   <51A39E11.5020405@yandex-team.ru>
	   <1369699930.3301.494.camel@edumazet-glaptop>
	   <51A47496.6000100@yandex-team.ru>
	   <1369787693.3301.586.camel@edumazet-glaptop>
	   <20130529013111.GS6172@linux.vnet.ibm.com>
	  <1369804097.3301.615.camel@edumazet-glaptop>
	  <51A5D3D9.1000106@yandex-team.ru>
	 <1369854387.5109.77.camel@edumazet-glaptop>
	 <51A70CF4.1020807@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Dipankar Sarma <dipankar@in.ibm.com>, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	David Laight <David.Laight@ACULAB.COM>
To: Roman Gushchin <klamm@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:51681 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755117Ab3FBXbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 19:31:38 -0400
In-Reply-To: <51A70CF4.1020807@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-30 at 12:25 +0400, Roman Gushchin wrote:
> On 29.05.2013 23:06, Eric Dumazet wrote:
> > On Wed, 2013-05-29 at 14:09 +0400, Roman Gushchin wrote:
> >
> > True, these lookup functions are usually structured the same around the
> > hlist_nulls_for_each_entry_rcu() loop.
> >
> > A barrier() right before the loop seems to be a benefit, the size of
> > assembly code is reduced by 48 bytes.
> >
> > And its one of the documented way to handle this kind of problems
> > (Documentation/atomic_ops.txt line 114)
> >
> > I guess we should amend this documentation, eventually.
> >
> > Thanks, please add you "Signed-off-by" if you agree with the patch.
> >
> 
> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
> 
> Many thanks to you, Paul E. McKenney and David Laight for your
> patches, help and participation in this discussion.

Thanks to you !

David, is there any problem with the patch ?

http://patchwork.ozlabs.org/patch/247360/ says "Not applicable", please
tell me what is needed to get it merged.

Thanks !
