From: Yoann Juet <veilletechno-irts@univ-nantes.fr>
Subject: Re: ixgbe: SR-IOV, macvlan filter on VFs
Date: Thu, 14 Aug 2014 17:27:28 +0200
Message-ID: <53ECD560.4000700@univ-nantes.fr>
References: <53ECA5C9.2020904@univ-nantes.fr> <53ECCC01.4050400@gmail.com>
Reply-To: Yoann Juet <veilletechno-irts@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yoann Juet <yoann.juet@univ-nantes.fr>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtptls2-lmb.cpub.univ-nantes.fr ([193.52.103.111]:44252 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754958AbaHNP1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 11:27:15 -0400
In-Reply-To: <53ECCC01.4050400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> hmm this should work I think.
>
> Did you set the VF mac address at some point with,
>
>      ip link set dev DEVICE vf NUM mac ADDR
>
> If not this how did you setup the virtual functions? Manually via
> sriov_numvfs? Or via libvirt or other library.

I'm using libvirt with interface type 'network' or 'hostdev'. The mac 
address is optional within this configuration block. But, If omitted, 
it's automatically generated. Even if I could set the mac address via 
the 'ip link' command (not very practical with libvirt but possible), 
Keepalived still needs two mac addresses per VF. From the guest perspective:
	- ethX: @mac1, @ip1
	- macvlanX<->ethX: @mac2 (vmac), @ip2 (vip)

Correct me if I'm wrong, the command 'ip link set dev DEVICE vf NUM mac 
ADDR' can only set one mac per VF.

Thanks,
Regards,
