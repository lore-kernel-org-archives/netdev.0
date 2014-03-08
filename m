From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are
 enabled
Date: Sat, 08 Mar 2014 08:08:03 -0800
Message-ID: <1394294883.20149.70.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	 <1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: Ming Chen <v.mingchen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:46548 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbaCHQIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 11:08:05 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so5481909pbb.0
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 08:08:04 -0800 (PST)
In-Reply-To: <1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-03-08 at 07:27 -0800, Eric Dumazet wrote:

> Quite frankly, with a 1Gbe link, I would just use FQ and your problem
> would disappear.
> 
> (I also use FQ with 40Gbe links if that matters)
> 
> For a 1Gbe link, the following command is more than enough.
> 
> tc qdisc replace dev eth0 root fq
> 
> Also, following patch would probably help fairness. I'll submit an
> official and more complete patch later.

Also try more recent kernels. TCP stack changes a lot these days ;)

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git

contains many TCP related stuff which should land in linux-3.15
