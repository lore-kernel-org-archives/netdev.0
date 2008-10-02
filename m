From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 33/33] Enable netfilter in netns
Date: Thu, 02 Oct 2008 11:12:08 +0200
Message-ID: <48E49068.5070305@trash.net>
References: <48C01046.2070704@trash.net> <1220842990-30500-33-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52487 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754665AbYJBJNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 05:13:08 -0400
In-Reply-To: <1220842990-30500-33-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> >From kernel perspective, allow entrance in nf_hook_slow().
>
> Stuff which uses nf_register_hook/nf_register_hooks, but otherwise not netns-ready:
>
> 	DECnet netfilter
> 	ipt_CLUSTERIP
> 	nf_nat_standalone.c together with XFRM (?)
> 	IPVS
> 	several individual match modules (like hashlimit)
> 	ctnetlink
> 	NOTRACK
> 	all sorts of queueing and reporting to userspace
> 	L3 and L4 protocol sysctls, bridge sysctls
> 	probably something else
>
> Anyway critical mass has been achieved, there is no reason to hide netfilter any longer.
>
> >From userspace perspective, allow to manipulate all sorts of                                                                                                                                                                                   
> iptables/ip6tables/arptables rules.
>   

Applied. thanks Alexey.

Is there an easy way to test all this stuff?

