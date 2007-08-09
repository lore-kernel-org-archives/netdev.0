From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 6/14] nes: hardware init
Date: Thu, 9 Aug 2007 11:56:44 +0100
Message-ID: <20070809115644.479a872c@oldman.hamilton.local>
References: <200708080105.l7815pC3004792@neteffect.com>
	<46B92342.9090802@garzik.org>
	<5E701717F2B2ED4EA60F87C8AA57B7CC07443E4D@venom2>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>, <rdreier@cisco.com>,
	<ewg@lists.openfabrics.org>, <netdev@vger.kernel.org>
To: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34282 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755762AbXHIK42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 06:56:28 -0400
In-Reply-To: <5E701717F2B2ED4EA60F87C8AA57B7CC07443E4D@venom2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

More comments

>---
>diff -Nurp NULL ofa_kernel-1.2/drivers/infiniband/hw/nes/nes_hw.c
>--- NULL	1969-12-31 18:00:00.000000000 -0600
>+++ ofa_kernel-1.2/drivers/infiniband/hw/nes/nes_hw.c	2007-08-06 20:09:04.000000000 -0500
>+
>+#include "nes.h"
>+u32 crit_err_count = 0;

Possible global namespace conflict.  You should make sure all global
symbols start with something specfic to driver like "nes_".

>+#include "nes_cm.h"
>+
>+
>+#ifdef NES_DEBUG
>+static unsigned char *nes_iwarp_state_str[] = {

Why use unsigned char? This should be "static const char *"
Maybe use gcc array initilaizers.
