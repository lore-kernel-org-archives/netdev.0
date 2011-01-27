From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: use RxFIFO overflow workaround for 8168c chipset
Date: Thu, 27 Jan 2011 15:32:19 +0100
Message-ID: <20110127143219.GA7831@electric-eye.fr.zoreil.com>
References: <1296127451-12640-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes <hayeswang@realtek.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44824 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990Ab1A0OeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 09:34:22 -0500
Content-Disposition: inline
In-Reply-To: <1296127451-12640-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vecera <ivecera@redhat.com> :
> I found that one of the 8168c chipsets (concretely XID 1c4000c0) starts
> generating RxFIFO overflow errors. The result is an infinite loop in
> interrupt handler as the RxFIFOOver is handled only for ...MAC_VER_11.

Acked-by: as your patch ties it to a specific 8168 revision (CFG_METHOD_6
in Realtek's parlance).

Surprizing as it may seem, unconditionaly enabling it has not always
produced the expected result. See 53f57357ff0afc37804f4e82ee3123e0c0a2cad6
for instance. Realtek's r1868 driver ignores it most of time as well.

Was it normal high-load or pktgen like high load ?

-- 
Ueimor
