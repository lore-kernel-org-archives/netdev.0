From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: natsemi.c ioctl fix or mii register access
Date: Sat, 24 May 2008 12:04:29 +0200
Message-ID: <20080524100429.GA11715@electric-eye.fr.zoreil.com>
References: <010200463BAAFF45926C5BFD8E21F515F523F0@cos-us-mb01.cos.agilent.com> <4835B5C0.2000701@pobox.com> <010200463BAAFF45926C5BFD8E21F515FD47AC@cos-us-mb01.cos.agilent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: glenn_engel@agilent.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46866 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754310AbYEXK3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2008 06:29:14 -0400
Content-Disposition: inline
In-Reply-To: <010200463BAAFF45926C5BFD8E21F515FD47AC@cos-us-mb01.cos.agilent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(please don't top post and quote only the relevant parts)

glenn_engel@agilent.com <glenn_engel@agilent.com> :
[...]
> I suppose this copy could be done in dev.c for these ioctls but it would
> also need to tweak the ifru_data field to point to local storage
> before/after the ioctl calls.  Perhaps this was the original intent and
> was not noticed since ethtool doesn't use these ioctls. I just assumed
> the natsemi driver was the odd duck but perhaps none of them work with
> these ioctls at this point.

The type-casting is a bit confusing at times but these ioctls work rather
well in real life, with mii-tool for instance.

-- 
Ueimor
