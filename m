From: David Miller <davem@davemloft.net>
Subject: Re: [klibc] [patch] import socket defines
Date: Thu, 10 Jan 2008 22:16:15 -0800 (PST)
Message-ID: <20080110.221615.188955433.davem@davemloft.net>
References: <477AF86E.1080309@zytor.com>
	<200801020830.43449.vapier@gentoo.org>
	<477BD374.6060506@zytor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vapier@gentoo.org, netdev@vger.kernel.org, klibc@zytor.com
To: hpa@zytor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45076
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751154AbYAKGQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 01:16:16 -0500
In-Reply-To: <477BD374.6060506@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H. Peter Anvin" <hpa@zytor.com>
Date: Wed, 02 Jan 2008 10:09:56 -0800

> Seems the most logical thing to do would be to break out the small 
> portion that everyone wants into <linux/sockaddr.h> or somesuch, and 
> then remove those ifdefs entirely.
> 
> Proposed patch (still being tested) attached...

I think this would clearly break existing glibc builds.

I agree with fixing the ifdef checks, but not like this.
