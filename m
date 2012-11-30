From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [net-next:master 98/98] drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34:
 sparse: cast to restricted __be16
Date: Fri, 30 Nov 2012 16:51:41 -0500
Message-ID: <50B92A6D.8000600@myri.com>
References: <50b91efa.B0WbOtcWMs7eOSaC%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:35867 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913Ab2K3Vvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 16:51:45 -0500
Received: by mail-gh0-f174.google.com with SMTP id g15so153323ghb.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 13:51:44 -0800 (PST)
In-Reply-To: <50b91efa.B0WbOtcWMs7eOSaC%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/12 16:02, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   1b4c44e6369dbbafd113f1e00b406f1eda5ab5b2
> commit: 1b4c44e6369dbbafd113f1e00b406f1eda5ab5b2 [98/98] myri10ge: Add vlan rx for better GRO perf.
> 
> 
> sparse warnings:
> 
> + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
> + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
> + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
> + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
> + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:16: sparse: restricted __be16 degrades to integer


OK, maybe a dumb question again, but how do I get sparse to produce
the 'cast to restricted' warnings?  I ran sparse before submission,
but it only showed the pre-existing, non "cast to restricted"
warnings, so I did not know I was introducing a new warning.
Do I need to use a different architecture? (I was using x86_64).

Also, the line it is warning about is this:

> 1b4c44e6 Andrew Gallatin 2012-11-30 @1286  	    veh->h_vlan_proto == ntohs(ETH_P_8021Q)) {


Which seems to be nearly identical to the usage in
if_vlan.h:__vlan_get_tag, which I was treating as canonical..
So I'm a bit confused as to how to fix it.


Thanks,

Drew
