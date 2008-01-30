From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] [SIS190] Constify data marked as __devinitdata
Date: Wed, 30 Jan 2008 14:31:05 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801301429230.15249@fbirervta.pbzchgretzou.qr>
References: <1201690388-9052-1-git-send-email-jonas@southpole.se>
 <Pine.LNX.4.64.0801301220570.15249@fbirervta.pbzchgretzou.qr>
 <20080130112559.GA21346@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jonas Bonn <jonas@southpole.se>, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, linux-kernel@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:50143 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbYA3NbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 08:31:07 -0500
In-Reply-To: <20080130112559.GA21346@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 30 2008 12:25, Sam Ravnborg wrote:
>
>We have just introduced __initconst, __cpuinitconst, __meminitconst
>for const data.
>So the patch is wrong.

Oh joy, more tags. Is it actually possible to combine const
with __devinitconst now?

static const uint16_t foo[] __devinitconst = { ... };
