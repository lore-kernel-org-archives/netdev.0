From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] r8169: Don't claim WoL works if LanWake flag is not
 set
Date: Thu, 10 Dec 2015 21:40:54 +0100
Message-ID: <20151210204054.GA30391@electric-eye.fr.zoreil.com>
References: <1449655730-3328-1-git-send-email-vinschen@redhat.com>
 <1449657826-4461-1-git-send-email-vinschen@redhat.com>
 <20151209224306.GA5082@electric-eye.fr.zoreil.com>
 <20151210095135.GA21583@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Chun-Hao Lin <hau@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58719 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbbLJUlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 15:41:07 -0500
Content-Disposition: inline
In-Reply-To: <20151210095135.GA21583@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
[...]
> I could do this (after I could lay my hands on such a board, that is),
> but I'm not convinced that this makes a lot of sense for two reasons.

Ok, let's get this change applied. Whatever happens should not be
hard to manage (I'm thinking about other boards or BIOSes relying on the
current - broken as it can be - behavior to work correctly).

[...]
> 1.  There is no global change in behaviour.  The usual way to handle the
>     WoL flags is to set the affected method flags and additionally set
>     LanWake if any of the method flags is set.  The fact that the method
>     flags don't enable WoL without also settting the LanWake flag is
>     documented.

I see no such thing in "7.5 Power Management Function" of the 8168c
registers datasheet. While Config3 states Magic Packet and Link Up
dependencies on Config1.PMEn, it says nothing about Config5.LanWake.

On old 8169 chipsets LanWake is autoloaded from EEPROM.

Plausible for Config5.{B, M, U}WF ? Ok.

Documented ? I am genuinely curious to know where.

-- 
Ueimor
