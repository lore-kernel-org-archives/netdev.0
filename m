From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH v3 0/8] CAIF Protocol Stack
Date: Mon, 30 Nov 2009 17:08:44 +0100
Message-ID: <4B13EE0C.7080000@trash.net>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefano.babic@babic.homelinux.org,
	randy.dunlap@oracle.com, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54291 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132AbZK3QIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 11:08:39 -0500
In-Reply-To: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> Change Log:
> 
> General:
> * Sockets has replaced the character device implementation,
>   when accessing the modem. AT channels has to open sockets.
> * CAIF Link layer is now implemented as net-devices.
> * Cleanup of asserts no using caif_assert everywhere.
> * Style cleanups, spacing, typedefs etc.
> 
> Documentation/CAIF
> * Removed tool chardevconfig for configuration.
>   Instead  CAIF NET device can be configured with RTNL or socket IOCTL.
> * Removed replaced user space tool ldiscd to configure TTY.
>   TTY is now opened from kernel when loading caif_serial.ko
> * Added caif socket MAN page to Documentation (Will be moved later on).
> * Added example on CAIF NET device configuration.
> * Removed reference to  Doc No: 155 19-CRH 109 913.
> 
> include/linux
> * Added caif_socket.h defining CAIF Socket interface.
> * Added if_caif.h define CAIF IP Net Device configuration
> 
> include/net
> * Added caif_dev.h defining interface between driver and caif-core.
> 
> include/net/generic
> * Updated assert statement
> * Removed typedefs
> 
> net/caif
> * Added socket implementation and removed character device.
> * General removed typedefs and fixed CHECKPATCH warnings
> * Minor change on error handling in cfcnfg.c
> * chnl_net.c Added RTNL support and IOCTL
> * Fixed typos in Kconfig

Please add the changelog to the respective patches and give them
meaningful subjects. Its impossible to review patches if you
don't even know what they're supposed to do.
