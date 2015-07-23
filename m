From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] openvswitch: fix compilation when vxlan is a
 module
Date: Thu, 23 Jul 2015 11:52:46 +0200
Message-ID: <20150723095246.GE22790@pox.localdomain>
References: <1437643747-22976-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, pshelar@nicira.com,
	dev@openvswitch.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34954 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbbGWJwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 05:52:50 -0400
Received: by wibxm9 with SMTP id xm9so200363547wib.0
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 02:52:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437643747-22976-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/23/15 at 11:29am, Nicolas Dichtel wrote:
> With CONFIG_VXLAN=m and CONFIG_OPENVSWITCH=y, there was the following
> compilation error:
>   LD      init/built-in.o
>   net/built-in.o: In function `vxlan_tnl_create':
>   .../net/openvswitch/vport-netdev.c:322: undefined reference to `vxlan_dev_create'
>   make: *** [vmlinux] Error 1
> 
> CC: Thomas Graf <tgraf@suug.ch>
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Thanks!

Acked-by: Thomas Graf <tgraf@suug.ch>
