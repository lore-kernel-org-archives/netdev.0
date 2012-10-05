From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: EG20T and Micrel KSZ9021 Gigabit Ethernet
Date: Fri, 5 Oct 2012 23:09:10 +0200
Message-ID: <20121005210910.GA10931@electric-eye.fr.zoreil.com>
References: <506F30A2.500@intcomgrp.com> <20121005195343.GA7083@electric-eye.fr.zoreil.com> <506F41FC.7080108@intcomgrp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Kosin <jkosin@intcomgrp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37018 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083Ab2JEV2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 17:28:52 -0400
Content-Disposition: inline
In-Reply-To: <506F41FC.7080108@intcomgrp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(please don't top post)

James Kosin <jkosin@intcomgrp.com> :
> The driver is always reporting:
>     [...] pch_gbe: Transfer Carrier Sense Error

You should send more information. Say dmesg, link stats (ip link),
ethtool information, stats and offload settings.

We have a small Micrel ksz9021 phy driver that the pch_gbe driver does
not use and the latter pokes into some phy specific register (0x10) that
the Micrel document does not include in its list of vendor registers...

Does your motherboard vendor offer some linux driver ?

/note to myself: pch_gbe should use standard mii.h registers instead
of defining its own redundant set of registers.

--
Ueimor
