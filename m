From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH v3] ucc_geth: Lockless xmit
Date: Tue, 25 Sep 2012 16:09:50 +0200
Message-ID: <OF79035384.7768EDE1-ONC1257A84.004D7D9C-C1257A84.004DCE48@transmode.se>
References: <1348129021-28333-1-git-send-email-Joakim.Tjernlund@transmode.se> <1348218675-3804-1-git-send-email-Joakim.Tjernlund@transmode.se> <20120921125129.GA21792@electric-eye.fr.zoreil.com> <OF6B2AFF0B.1C979828-ONC1257A80.00502DCF-C1257A80.00509C7E@LocalDomain> <OF53C63B27.8D5BE7C3-ONC1257A80.00575156-C1257A80.005766FC@transmode.se> <20120921173535.GA27934@electric-eye.fr.zoreil.com> <OF39977762.2BDD4BB8-ONC1257A82.0032A26B-C1257A82.00350A53@transmode.se> <20120924211014.GA17378@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:61868 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750803Ab2IYOJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 10:09:54 -0400
In-Reply-To: <20120924211014.GA17378@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> wrote on 2012/09/24 23:10:14:
>
> Joakim Tjernlund <joakim.tjernlund@transmode.se> :
> [...]
> > I don't get it. The skb test is there just for one special case, when
> > the BD ring is empty the (bd_status & T_R) == 0 will be true as well so
> > one need something more than the bd_status test.
>
> Sure but the converse is not true : (bd_status & T_R) == 0 && skb does not
> mean that the skb has been sent. It happens when said skb is about to be
> given to the hardware by hard_start_xmit as well.

duhh, I was too tired when trying to make sense of smp & racing in general, thanks.

Will probably be some time before I get to this again due to other stuff though.
The other patches are independent of this one, I hope they are good/accepted?

  Jocke
