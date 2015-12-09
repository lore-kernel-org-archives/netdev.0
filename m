From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] r8169: Don't claim WoL works if LanWake flag is not
 set
Date: Wed, 9 Dec 2015 23:43:06 +0100
Message-ID: <20151209224306.GA5082@electric-eye.fr.zoreil.com>
References: <1449655730-3328-1-git-send-email-vinschen@redhat.com>
 <1449657826-4461-1-git-send-email-vinschen@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55559 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbbLIWnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 17:43:17 -0500
Content-Disposition: inline
In-Reply-To: <1449657826-4461-1-git-send-email-vinschen@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
[...]
> This patch is supposed to fix this behaviour.  If LanWake is 0, the
> function now returns 0.  Thus ethtool correctly reports "Wake-on: d".

Can you turn it into a DMI controlled one (something like
drivers/net/ethernet/marvell/skge.c use of dmi_check_system) in order to
avoid a global change of behavior ?

Btw it's probably time to emit some warning during driver probe if wol
bits are not consistent with LanWake.

-- 
Ueimor
