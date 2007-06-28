From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: 2.6.22rc6+patches works, but 2.6.21.5 and 2.6.22rc6 without patches->network transfer blocking
Date: Thu, 28 Jun 2007 23:30:50 +0200
Message-ID: <20070628213050.GB4233@electric-eye.fr.zoreil.com>
References: <4683F923.80508@bcsoft.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev list <netdev@vger.kernel.org>
To: Jens Stroebel <drifter@bcsoft.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58943 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759446AbXF1Vdm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 17:33:42 -0400
Content-Disposition: inline
In-Reply-To: <4683F923.80508@bcsoft.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jens Stroebel <drifter@bcsoft.de> :
[...]
> Is there any possibility to get this fix working in 2.6.21.5? Would it
> be possible to apply the single patch to 2.6.21.5 and get a working
> driver? Or would it be possible to create the fixing patch for the
> driver in 2.6.21.5?

Mantra: mainline first, stable later.

In the next future, most of this patchset will hopefully go into
2.6.23-rc1. Some people will then complain that 2.6.23-rc1 breaks
their 816x. After that the patchkit will be amended and the r8169
regressions in 2.6.23-rcX fixed.

Then it will be time to feed some r8169 bits in 2.6.2x.y

It may help and/or accelerate things if you can narrow the fix(es) in
the current r8169 serie.

-- 
Ueimor
