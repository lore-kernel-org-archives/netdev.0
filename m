From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] net: EMAC: Fix problem with mtu > 4080 on non TAH  equipped 4xx PPC's
Date: Wed, 16 Jan 2008 06:34:11 +0100
Message-ID: <200801160634.11745.sr@denx.de>
References: <1200400809-19720-1-git-send-email-sr@denx.de> <200801152046.01881.sr@denx.de> <20080115200019.GA2598@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:53208 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbYAPFej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 00:34:39 -0500
In-Reply-To: <20080115200019.GA2598@gate.ebshome.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 15 January 2008, Eugene Surovegin wrote:
> > OK. But how do we detect GigE support? Seems like GigE enabled devices
> > have CONFIG_IBM_EMAC4 defined. If nobody objects I'll fix up another
> > version tomorrow.
>
> Look couple of lines down where I set MTU changing hook. If you cannot
> change MTU you cannot get big frames.

Ahhh, I must have been blind. Thanks for pointing out.

I'll send new patches for ibm_emac and ibm_newemac in a short while.

Best regards,
Stefan
