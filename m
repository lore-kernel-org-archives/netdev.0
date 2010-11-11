From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Regression 2.6.36 - driver rtl8169 crashes kernel, triggered by
 user app
Date: Thu, 11 Nov 2010 21:49:55 +0100
Message-ID: <20101111204955.GA8348@electric-eye.fr.zoreil.com>
References: <201011111933.04343@zmi.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Monnerie <michael.monnerie@is.it-management.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 254.185.140-88.rev.gaoland.net ([88.140.185.254]:40366 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756759Ab0KKUuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 15:50:08 -0500
Content-Disposition: inline
In-Reply-To: <201011111933.04343@zmi.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Monnerie <michael.monnerie@is.it-management.at> :
[...]
> With kernel 2.6.34.7-0.5-desktop, this runs with ~41MiB/s without 
> problems.
> 
> With kernel 2.6.36, it runs at ~26MiB/s, and while doing so, dmesg shows 
> a lot of noise about r8169 complaining:
> http://zmi.at/x/kernel2.6.36-crash86.jpg

Can you test again after reverting 801e147cde02f04b5c2f42764cd43a89fc7400a2 ?

Thanks.

-- 
Ueimor
