From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] r8169: use RxFIFO overflow workaround for 8168c chipset
Date: Thu, 27 Jan 2011 20:23:36 +0100
Message-ID: <1296156217.8720.3.camel@ceranb.brq.redhat.com>
References: <1296127451-12640-1-git-send-email-ivecera@redhat.com>
	 <20110127143219.GA7831@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hayes <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752680Ab1A0TXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jan 2011 14:23:50 -0500
In-Reply-To: <20110127143219.GA7831@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-01-27 at 15:32 +0100, Francois Romieu wrote:
> Ivan Vecera <ivecera@redhat.com> :
> > I found that one of the 8168c chipsets (concretely XID 1c4000c0) starts
> > generating RxFIFO overflow errors. The result is an infinite loop in
> > interrupt handler as the RxFIFOOver is handled only for ...MAC_VER_11.
> 
> Acked-by: as your patch ties it to a specific 8168 revision (CFG_METHOD_6
> in Realtek's parlance).
> 
> Surprizing as it may seem, unconditionaly enabling it has not always
> produced the expected result. See 53f57357ff0afc37804f4e82ee3123e0c0a2cad6
> for instance. Realtek's r1868 driver ignores it most of time as well.
> 
> Was it normal high-load or pktgen like high load ?
The test case was: Migration of the several kvm guests at the same time
between two hosts.

Ivan

