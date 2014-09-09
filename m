From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 3/8] Documentation: bindings: net: add the Marvell PXA168 Ethernet controller
Date: Tue, 09 Sep 2014 17:58:12 +0200
Message-ID: <3827594.chb831jyvc@wuerfel>
References: <1410273848-24663-1-git-send-email-antoine.tenart@free-electrons.com> <1410273848-24663-4-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: sebastian.hesselbarth@gmail.com,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:54641 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844AbaIIP6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 11:58:49 -0400
In-Reply-To: <1410273848-24663-4-git-send-email-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 09 September 2014 16:44:03 Antoine Tenart wrote:
> +- clocks: pointer to the clock for the device.
> +- clock-names: should be "MFUCLK".

Clock names are normally not capitalized. Are you able to change
that name when providing a binding or make it an anoymous clock?
What does MFU stand for anyway?

	Arnd
