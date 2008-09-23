From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169, linux kernel 2.6.22.9, broken negotiation
Date: Tue, 23 Sep 2008 22:44:53 +0200
Message-ID: <20080923204453.GA12519@electric-eye.fr.zoreil.com>
References: <48D8B60F.8060102@linux.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shuchen@realtek.com.tw, netdev@vger.kernel.org
To: Antonio Gallo <agx@linux.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40358 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752536AbYIWUpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 16:45:06 -0400
Content-Disposition: inline
In-Reply-To: <48D8B60F.8060102@linux.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Antonio Gallo <agx@linux.it> :
[...]
> Should i try the r8168.ko from the realtek web site instead of the kernel 
> module r8169 ?

I think that it is fixed by commit 66ec5d4fb1ce6f0bd9df4bc4b758f0916d9f37ab
in mainline (merged between 2.6.23 and 2.6.24).

You can either use Realtek's driver or try a recent 2.6.27-rc, optionally
patched with http://userweb.kernel.org/~romieu/r8169/2.6.27-rc6/

-- 
Ueimor
