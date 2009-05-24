From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sun, 24 May 2009 23:15:57 +0200
Message-ID: <20090524211557.GA14634@electric-eye.fr.zoreil.com>
References: <1242001754.4093.12.camel@obelisk.thedillows.org> <200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de> <1242077392.3716.15.camel@lap75545.ornl.gov> <4A09DC3E.2080807@googlemail.com> <1242268709.4979.7.camel@obelisk.thedillows.org> <4A0C6504.8000704@googlemail.com> <1242328457.32579.12.camel@lap75545.ornl.gov> <4A0C7443.1010000@googlemail.com> <1243042174.3580.23.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?unknown-8bit?B?QsO8a2Vy?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:45819 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753350AbZEXVPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 May 2009 17:15:02 -0400
Content-Disposition: inline
In-Reply-To: <1243042174.3580.23.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Dillow <dave@thedillows.org> :
[...]
> This fixes the lockups I've seen. Both MSI and level-triggered interrupt
> configurations survive over an hour of testing when it would lockup in
> under 90 seconds before. I am certain of the analysis of the root cause,
> but there may be better ways to fix it. There may also be a theoretical
> race window between the ending of a NAPI poll cycle and a link change
> interrupt coming in, but I'm not sure it would matter. 

It makes sense.

If I understand correctly, one should expect to find some pending Tx
event in the ISR of a failed card when reading the registers with
ethtool.

Has someone noticed it ?

-- 
Ueimor
