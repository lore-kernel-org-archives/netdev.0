From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 01/11] fs_enet: Add support for MPC512x to fs_enet driver
Date: Wed, 20 Jan 2010 11:02:42 -0600
Message-ID: <4B573732.3030000@freescale.com>
References: <1263932653-3634-1-git-send-email-agust@denx.de>	<1263932653-3634-2-git-send-email-agust@denx.de>	<4B561AA3.7040506@freescale.com> <20100120122058.1539412b@wker>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, wd@denx.de,
	John Rigby <jrigby@freescale.com>, netdev@vger.kernel.org,
	dzu@denx.de, Piotr Ziecik <kosmo@semihalf.com>
To: Anatolij Gustschin <agust@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:64502 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748Ab0ATRFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 12:05:14 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id o0KH59ZO010770
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2010 10:05:09 -0700 (MST)
Received: from az33exm25.fsl.freescale.net (az33exm25.am.freescale.net [10.64.32.16])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id o0KHAZkC010021
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2010 11:10:35 -0600 (CST)
In-Reply-To: <20100120122058.1539412b@wker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anatolij Gustschin wrote:
> Scott Wood <scottwood@freescale.com> wrote:
>> You can put a data pointer in the of_platform match struct, instead of 
>> re-checking the compatible.
> 
> .data pointer in 'fs_enet_mdio_fec_match' is already used for
> mpc5xxx_get_bus_frequency(). Setting .data to some sort of FEC ID in
> match struct for "fsl,pq1-fec-mdio" would be confusing to.

You could point .data to a struct if there are multiple things.

-Scott
