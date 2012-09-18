From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/5] ucc_geth: Reduce IRQ off in xmit path
Date: Wed, 19 Sep 2012 00:39:38 +0200
Message-ID: <20120918223938.GA22868@electric-eye.fr.zoreil.com>
References: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51024 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932256Ab2IRW5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 18:57:44 -0400
Content-Disposition: inline
In-Reply-To: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund <Joakim.Tjernlund@transmode.se> :
> Currently ucc_geth_start_xmit wraps IRQ off for the
> whole body just to be safe.
> Reduce the IRQ off period to a minimum.

The driver does not do much work in its irq handler. You may as well
convert it to the usual tg3-ish locking style (i.e. almost no locking).

-- 
Ueimor
