From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] openvswitch: fix compilation when vxlan is a
 module
Date: Mon, 27 Jul 2015 10:33:52 +0200
Message-ID: <20150727083352.GA25211@pox.localdomain>
References: <1437643747-22976-1-git-send-email-nicolas.dichtel@6wind.com>
 <20150726.205742.539016799227504892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	pshelar@nicira.com, dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:33099 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbbG0Id4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:33:56 -0400
Received: by wicmv11 with SMTP id mv11so129137588wic.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 01:33:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150726.205742.539016799227504892.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/26/15 at 08:57pm, David Miller wrote:
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Thu, 23 Jul 2015 11:29:07 +0200
> 
> > With CONFIG_VXLAN=m and CONFIG_OPENVSWITCH=y, there was the following
> > compilation error:
> >   LD      init/built-in.o
> >   net/built-in.o: In function `vxlan_tnl_create':
> >   .../net/openvswitch/vport-netdev.c:322: undefined reference to `vxlan_dev_create'
> >   make: *** [vmlinux] Error 1
> > 
> > CC: Thomas Graf <tgraf@suug.ch>
> > Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> > Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> Applied as a stop-gap measure to fix this, but this is a terrible
> dependency.
> 
> There is no reason a user should have to know that without vxlan
> they aren't able to turn on openvswitch.

I'm working on a patch to re-enable this choice.
