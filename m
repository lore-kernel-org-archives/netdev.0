From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: Re: [PATCH] Marvell phy: add fiber status check for some components
Date: Mon, 4 Apr 2016 10:45:42 +0200
Message-ID: <570229B6.4090805@nexvision.fr>
References: <56FE9B5C.6030509@nexvision.fr> <56FEA2EC.2030303@nexvision.fr>
 <20160401170838.GA21633@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 19.mo4.mail-out.ovh.net ([87.98.179.66]:53462 "EHLO
	19.mo4.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810AbcDDIpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 04:45:46 -0400
Received: from mail699.ha.ovh.net (b6.ovh.net [213.186.33.56])
	by mo4.mail-out.ovh.net (Postfix) with SMTP id AA20610600B2
	for <netdev@vger.kernel.org>; Mon,  4 Apr 2016 10:45:44 +0200 (CEST)
In-Reply-To: <20160401170838.GA21633@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Shouldn't you return to page 0, i.e. MII_M1111_COPPER, under all
> conditions?

I return marvell_read_status() which returns 0 if it hasn't error during the process.
In case of right conditions, my function returns 0 for COPPER part (and FIBER part too).

It doesn't change the value returned and behavior.

Charles-Antoine
