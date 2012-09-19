From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH 1/5] ucc_geth: Reduce IRQ off in xmit path
Date: Wed, 19 Sep 2012 09:36:10 +0200
Message-ID: <OFC5B92135.593A5C37-ONC1257A7E.0029904D-C1257A7E.0029C39F@transmode.se>
References: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se> <20120918223938.GA22868@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:53513 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754922Ab2ISHgN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 03:36:13 -0400
In-Reply-To: <20120918223938.GA22868@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> wrote on 2012/09/19 00:39:38:
>
> Joakim Tjernlund <Joakim.Tjernlund@transmode.se> :
> > Currently ucc_geth_start_xmit wraps IRQ off for the
> > whole body just to be safe.
> > Reduce the IRQ off period to a minimum.
>
> The driver does not do much work in its irq handler. You may as well
> convert it to the usual tg3-ish locking style (i.e. almost no locking).

You mean broadcom/tg3.c? It is a bit much to look at ATM for me and
there almost no locking with my patch also. Could possibly
be improved further but I am happy for now.

 Jocke
