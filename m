From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH] net: Do not wrap sysctl igmp_max_memberships in IP_MULTICAST
Date: Wed, 13 Apr 2011 00:41:01 +0200
Message-ID: <OFC79D071E.07C0B656-ONC1257870.007C4E97-C1257870.007C9B15@transmode.se>
References: <1302601774-24289-1-git-send-email-Joakim.Tjernlund@transmode.se> <20110412.140016.189701267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:51789 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901Ab1DLWlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 18:41:05 -0400
In-Reply-To: <20110412.140016.189701267.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David Miller <davem@davemloft.net> wrote on 2011/04/12 23:00:16:
>
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: Tue, 12 Apr 2011 11:49:34 +0200
>
> > controlling igmp_max_membership is useful even when IP_MULTICAST
> > is off.
> > Quagga(an OSPF deamon) uses multicast addresses for all interfaces
> > using a single socket and hits igmp_max_membership limit when
> > there are 20 interfaces or more.
> > Always export sysctl igmp_max_memberships in proc, just like
> > igmp_max_msf
> >
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
>
> I really like your commit message, a full justification and a
> reference to existing similar behavior.
>
> If only every patch submitter did this :-/

Thanks, I really wish all my commit msgs are like the above.

 Jocke

