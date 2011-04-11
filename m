From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: igmp_max_memberships and CONFIG_IP_MULTICAST
Date: Mon, 11 Apr 2011 23:33:57 +0200
Message-ID: <OF1532333A.0F6C481C-ONC125786F.007640A0-C125786F.00767713@transmode.se>
References: <OF8B112606.401AF255-ONC125786F.006B302C-C125786F.006B840C@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:59823 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753167Ab1DKVeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 17:34:00 -0400
Received: from sesr04.transmode.se (sesr04.transmode.se [192.168.201.15])
	by gw1.transmode.se (Postfix) with ESMTP id 5679D258027
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 23:33:58 +0200 (CEST)
In-Reply-To: <OF8B112606.401AF255-ONC125786F.006B302C-C125786F.006B840C@LocalDomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund/Transmode wrote on 2011/04/11 21:34:21:
>
> Why is igmp_max_memberships hidden behind CONFIG_IP_MULTICAST?
>
> I am running Quagga(OSPF) without CONFIG_IP_MULTICAST and ran into
> this limit. Now I need to increase it but then I find it is hidden behind
> CONFIG_IP_MULTICAST. Is there a reason it is hidden?
>

I should have been clearer, would you accept a patch which removes
CONFIG_IP_MULTICAST requirement for changing igmp_max_memberships
via proc?

 Jocke

