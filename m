From: Yoann Juet <veilletechno-irts@univ-nantes.fr>
Subject: Re: ixgbe: SR-IOV, macvlan filter on VFs
Date: Thu, 14 Aug 2014 17:56:52 +0200
Message-ID: <53ECDC44.5030300@univ-nantes.fr>
References: <53ECA5C9.2020904@univ-nantes.fr> <53ECCC01.4050400@gmail.com> <53ECD560.4000700@univ-nantes.fr> <53ECD82B.6080209@intel.com>
Reply-To: Yoann Juet <veilletechno-irts@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yoann Juet <yoann.juet@univ-nantes.fr>
To: John Fastabend <john.r.fastabend@intel.com>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtptls2-lmb.cpub.univ-nantes.fr ([193.52.103.111]:58243 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755214AbaHNP4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 11:56:39 -0400
In-Reply-To: <53ECD82B.6080209@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Right this seems to be the case. My guess is libvirt uses the IFLA_VF_MAC
> attribute to set the MAC from the host side. After this is done the PF
> driver will deny any additional MAC requests from the VF which is where
> you get that error message.
>
> I need to check the libvirt theory but if that is the case I'm not sure
> what the best fix off hand is. Maybe an option to libvirt not to set the
> MAC via the PF. The other option would be to add another knob to allow the
> setting of MAC addrs from the VF via 'ip link' similar to the TX spoofing
> bit already in place. Both would presumably resolve your use case.
>
> .John

Thanks a lot for your assistance John. Hope that a fix will be found 
regarding this issue.

Yoann.
