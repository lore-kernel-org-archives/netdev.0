From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3] ucc_geth: Lockless xmit
Date: Mon, 24 Sep 2012 23:10:14 +0200
Message-ID: <20120924211014.GA17378@electric-eye.fr.zoreil.com>
References: <1348129021-28333-1-git-send-email-Joakim.Tjernlund@transmode.se> <1348218675-3804-1-git-send-email-Joakim.Tjernlund@transmode.se> <20120921125129.GA21792@electric-eye.fr.zoreil.com> <OF6B2AFF0B.1C979828-ONC1257A80.00502DCF-C1257A80.00509C7E@LocalDomain> <OF53C63B27.8D5BE7C3-ONC1257A80.00575156-C1257A80.005766FC@transmode.se> <20120921173535.GA27934@electric-eye.fr.zoreil.com> <OF39977762.2BDD4BB8-ONC1257A82.0032A26B-C1257A82.00350A53@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36567 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943Ab2IXV2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 17:28:52 -0400
Content-Disposition: inline
In-Reply-To: <OF39977762.2BDD4BB8-ONC1257A82.0032A26B-C1257A82.00350A53@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund <joakim.tjernlund@transmode.se> :
[...]
> I don't get it. The skb test is there just for one special case, when
> the BD ring is empty the (bd_status & T_R) == 0 will be true as well so
> one need something more than the bd_status test.

Sure but the converse is not true : (bd_status & T_R) == 0 && skb does not
mean that the skb has been sent. It happens when said skb is about to be
given to the hardware by hard_start_xmit as well.

-- 
Ueimor
