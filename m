From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: natsemi.c ioctl fix or mii register access
Date: Fri, 16 May 2008 22:57:05 +0200
Message-ID: <20080516205705.GA19586@electric-eye.fr.zoreil.com>
References: <010200463BAAFF45926C5BFD8E21F515F523F0@cos-us-mb01.cos.agilent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: glenn_engel@agilent.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37701 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751824AbYEPVWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 17:22:01 -0400
Content-Disposition: inline
In-Reply-To: <010200463BAAFF45926C5BFD8E21F515F523F0@cos-us-mb01.cos.agilent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(please shorten your lines below 80 cols)

glenn_engel@agilent.com <glenn_engel@agilent.com> :
[...]
> The specific problems noted and fixed:
> 
> 1. The if_mii macro casts it's return to be (struct mii_ioctl_data *) but
> in reality it returns a pointer to the user space pointer (struct
> mii_ioctl_data**).   This looks to be a problem with the mii_macro to me.
> I changed this to use the ifr_data macro instead.

Which user space application did you read the source of ?

Afaiks the kernel side looks very similar to any usual network device
driver ioctl.

> 2. Since the mii_ioctl_data structure resides in user space, it must be
> copied into kernel space before access and copied back for read results.

Is not it what net/core/dev.c::dev_ioctl does.

-- 
Ueimor
