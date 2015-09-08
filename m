From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 3/3] r8169: increase the lifespan of the hardware
 counters dump area.
Date: Wed, 9 Sep 2015 01:27:58 +0200
Message-ID: <20150908232758.GA28427@electric-eye.fr.zoreil.com>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
 <fb3db9039225ed3a030e779565b8e11f99fc8ae2.1441454454.git.romieu@fr.zoreil.com>
 <20150906103732.GF30539@calimero.vinschen.de>
 <20150907144412.GA26524@calimero.vinschen.de>
 <20150907215251.GA4897@electric-eye.fr.zoreil.com>
 <20150908000202.GA5059@electric-eye.fr.zoreil.com>
 <20150908202315.GH20288@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35307 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbbIHX2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 19:28:31 -0400
Content-Disposition: inline
In-Reply-To: <20150908202315.GH20288@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
[...]
> - Alternatively I can still reproduce the SEGV in rtl_remove_one
>   when trying to rmmod the module, I just don't have the stack dump
>   handy while writing this mail.  I can show it if needed.

I see it too. 

> I debugged this on and off the entire day (tweaking, compiling, rebooting,
> kernel crash, rinse and repeat).
> 
> And the result of my debugging is totally crazy:

My patch corrupts memory.

-- 
Ueimor
