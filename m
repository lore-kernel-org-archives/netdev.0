From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] cls_cgroup: Fix oops when user send improperly 'tc
 filter add' request
Date: Tue, 09 Jun 2009 04:03:19 -0700 (PDT)
Message-ID: <20090609.040319.219370461.davem@davemloft.net>
References: <20090609085408.9b38ffe1.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	tgraf@suug.ch, hadi@cyberus.ca, jarkao2@gmail.com
To: usui@mxm.nes.nec.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35925
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755035AbZFILDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 07:03:17 -0400
In-Reply-To: <20090609085408.9b38ffe1.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Date: Tue, 9 Jun 2009 08:54:08 +0900

> cls_cgroup: Fix oops when user send improperly 'tc filter add' request
> 
> I found a bug in cls_cgroup_change() in cls_cgroup.c.
> cls_cgroup_change() expected tca[TCA_OPTIONS] was set from user space properly,
> but tc in iproute2-2.6.29-1 (which I used) didn't set it.
> 
> In the current source code of tc in git, it set tca[TCA_OPTIONS].
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
> 
> If we always use a newest iproute2 in git when we use cls_cgroup, 
> we don't face this oops probably.
> But I think, kernel shouldn't panic regardless of use program's behaviour. 
> 
> Signed-off-by: Minoru Usui <usui@mxm.nes.nec.co.jp>

Patch applied, thank you.
