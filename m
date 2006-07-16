From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [2.6 patch] drivers/net/wireless/zd1211rw/: possible cleanups
Date: Sun, 16 Jul 2006 14:17:13 +0100
Message-ID: <44BA3C59.9030503@gentoo.org>
References: <20060715003511.GE3633@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:45458 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1946010AbWGPNKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 09:10:50 -0400
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060715003511.GE3633@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch contains the following possible cleanups:
> - make needlessly global functions static
> - #if 0 unused functions
> 
> Please review which of these functions do make sense and which do 
> conflict with pending patches.

Thanks Adrian. I have put this in my tree and made an additional change 
along the same lines (your patched introduced an unused function warning 
to the non-debug build). If Ulrich signifies acceptance, I will send 
this on to John.

I have also sent in a patch to add a MAINTAINERS entry for zd1211rw, in 
hope that this will help you send patches with myself and/or Ulrich CC'd 
in future :)

Thanks.
Daniel
